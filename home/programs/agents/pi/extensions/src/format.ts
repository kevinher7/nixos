import { access, readFile } from "node:fs/promises";
import { constants } from "node:fs";
import { homedir } from "node:os";
import { delimiter, dirname, extname, join, resolve } from "node:path";
import { withFileMutationQueue, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Effect } from "effect";
import { parse } from "smol-toml";

const javascriptExtensions = new Set([
  ".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs", ".json", ".jsonc",
  ".css", ".scss", ".md", ".mdx", ".html", ".vue", ".svelte", ".yml", ".yaml",
]);

async function findExecutable(name: string, localPath: string) {
  for (const path of [localPath, ...(process.env.PATH ?? "").split(delimiter).filter(Boolean).map((dir) => join(dir, name))]) {
    if (await access(path, constants.X_OK).then(() => true, () => false)) return path;
  }
  throw new Error(`${name} is configured but not installed`);
}

async function readOptional(path: string) {
  try {
    return await readFile(path, "utf8");
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === "ENOENT") return undefined;
    throw error;
  }
}

export async function findFormatter(file: string) {
  const extension = extname(file).toLowerCase();
  const python = extension === ".py" || extension === ".pyi";
  const nix = extension === ".nix";
  if (!python && !nix && !javascriptExtensions.has(extension)) return;

  for (let root = dirname(file); ; root = dirname(root)) {
    if (nix) {
      if (await readOptional(join(root, "flake.nix")) !== undefined
        && await readOptional(join(root, "treefmt.nix")) !== undefined) {
        return { command: "nix", args: ["fmt", "--offline", "--no-write-lock-file", "--", file], cwd: root };
      }
      if (root === homedir() || root === dirname(root)) return;
      continue;
    }
    const manifest = await readOptional(join(root, python ? "pyproject.toml" : "package.json"));
    if (manifest !== undefined) {
      if (python) {
        const project = parse(manifest);
        const tools = project.tool as Record<string, unknown> | undefined;
        const hasRuffConfig = tools?.ruff !== undefined
          || await readOptional(join(root, "ruff.toml")) !== undefined
          || await readOptional(join(root, ".ruff.toml")) !== undefined;
        const dependencyLists = [
          (project.project as Record<string, unknown> | undefined)?.dependencies,
          ...Object.values((project["dependency-groups"] ?? {}) as Record<string, unknown>),
          ...Object.values(((project.project as Record<string, unknown> | undefined)?.["optional-dependencies"] ?? {}) as Record<string, unknown>),
        ];
        const declaresRuff = dependencyLists.some((deps) => Array.isArray(deps)
          && deps.some((dep) => typeof dep === "string" && /^ruff(?:\s|\[|[<>=!~;@]|$)/i.test(dep)));
        const poetry = tools?.poetry as Record<string, unknown> | undefined;
        const poetryGroups = [poetry, ...Object.values((poetry?.group ?? {}) as Record<string, Record<string, unknown>>)];
        const poetryRuff = poetryGroups.some((group) => group
          && [group.dependencies, group["dev-dependencies"]].some((deps) => deps && Object.hasOwn(deps, "ruff")));
        if (!hasRuffConfig && !declaresRuff && !poetryRuff) return;
        const command = await findExecutable("ruff", join(root, ".venv", "bin", "ruff"));
        return { command, args: ["format", file], cwd: root };
      }

      const project = JSON.parse(manifest);
      const dependencies = { ...project.dependencies, ...project.devDependencies, ...project.optionalDependencies };
      for (const [dependency, binary, args] of [
        ["@biomejs/biome", "biome", ["format", "--write"]],
        ["oxfmt", "oxfmt", ["--write"]],
        ["prettier", "prettier", ["--write"]],
      ] as const) {
        if (Object.hasOwn(dependencies, dependency)) {
          const command = await findExecutable(binary, join(root, "node_modules", ".bin", binary));
          return { command, args: [...args, file], cwd: root };
        }
      }
      return;
    }
    if (root === homedir() || root === dirname(root)) return;
  }
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_result", async (event, ctx) => {
    if (event.isError || !["write", "edit"].includes(event.toolName) || typeof event.input.path !== "string") return;
    const path = event.input.path;
    const file = resolve(ctx.cwd, path.startsWith("~/") ? join(homedir(), path.slice(2)) : path);
    const message = await withFileMutationQueue(file, () => Effect.runPromise(
      Effect.tryPromise({
        try: () => findFormatter(file),
        catch: (error) => error instanceof Error ? error : new Error(String(error)),
      }).pipe(
        Effect.flatMap((formatter) => {
          if (!formatter) return Effect.succeed(undefined);
          return Effect.tryPromise({
            try: (signal) => pi.exec(formatter.command, formatter.args, {
              cwd: formatter.cwd,
              timeout: 10000,
              signal,
            }),
            catch: (error) => error instanceof Error ? error : new Error(String(error)),
          }).pipe(Effect.flatMap((result) => {
            if (result.killed) return Effect.fail(new Error("formatter timed out or was cancelled"));
            if (result.code !== 0) return Effect.fail(new Error(result.stderr.trim().slice(0, 500) || `formatter exited ${result.code}`));
            return Effect.succeed(`Formatted ${path}. Read the file again before editing it.`);
          }));
        }),
        Effect.catchAll((error) => Effect.succeed(`Formatting ${path} failed: ${error.message}`)),
      ),
      { signal: ctx.signal },
    )).catch((error: unknown) => ctx.signal?.aborted ? undefined : `Formatting ${path} failed: ${String(error)}`);

    if (message) return { content: [...event.content, { type: "text" as const, text: message }] };
  });
}
