import assert from "node:assert/strict";
import { chmod, mkdir, mkdtemp, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { test, type TestContext } from "node:test";
import type { ExtensionAPI, ExtensionContext, ExecResult } from "@earendil-works/pi-coding-agent";
import format, { findFormatter } from "../src/format.ts";
import rtk from "../src/rtk.ts";

type Handler = (event: unknown, context: ExtensionContext) => Promise<unknown>;
const success: ExecResult = { stdout: "", stderr: "", code: 0, killed: false };

function setup(extension: (pi: ExtensionAPI) => void, execute: ExtensionAPI["exec"]) {
  const handlers = new Map<string, Handler>();
  extension({
    on: (name: string, handler: Handler) => {
      handlers.set(name, handler);
      return () => handlers.delete(name);
    },
    exec: execute,
  } as unknown as ExtensionAPI);
  return (name: string, event: unknown, cwd = tmpdir(), signal?: AbortSignal) =>
    handlers.get(name)!(event, { cwd, signal, hasUI: false } as ExtensionContext);
}

async function project(t: TestContext) {
  const root = await mkdtemp(join(tmpdir(), "pi-extensions-"));
  t.after(() => rm(root, { recursive: true, force: true }));
  return async (path: string, content: string, executable = false) => {
    const file = join(root, path);
    await mkdir(dirname(file), { recursive: true });
    await writeFile(file, content);
    if (executable) await chmod(file, 0o755);
    return file;
  };
}

test("RTK rewrites only Bash input and preserves execution options", async () => {
  const run = setup(rtk, async (command, args, options) => {
    assert.equal(command, "rtk");
    assert.deepEqual(args, ["rewrite", "--", "git status"]);
    assert.equal(options?.timeout, 1000);
    assert.equal(options?.cwd, "/workspace");
    assert.ok(options?.signal);
    return { ...success, stdout: "rtk git status\n" };
  });
  const event = { toolName: "bash", input: { command: "git status", timeout: 30 } };
  await run("tool_call", event, "/workspace");
  assert.deepEqual(event.input, { command: "rtk git status", timeout: 30 });
  await run("tool_call", { toolName: "read", input: { path: "file" } });
});

test("RTK failures, unsupported commands, empty output and timeouts leave input unchanged", async () => {
  for (const result of [
    { ...success, code: 1 },
    success,
    { ...success, killed: true, stdout: "rtk git status" },
    new Error("rtk is missing"),
  ]) {
    const run = setup(rtk, async () => {
      if (result instanceof Error) throw result;
      return result;
    });
    const event = { toolName: "bash", input: { command: "git status" } };
    await run("tool_call", event);
    assert.equal(event.input.command, "git status");
  }
});

test("RTK cancellation reaches the subprocess and does not change input", async () => {
  const controller = new AbortController();
  const run = setup(rtk, async (_command, _args, options) => {
    return new Promise((resolve) => {
      options!.signal!.addEventListener("abort", () => resolve({ ...success, killed: true }), { once: true });
      controller.abort();
    });
  });
  const event = { toolName: "bash", input: { command: "git status" } };
  await run("tool_call", event, tmpdir(), controller.signal);
  assert.equal(event.input.command, "git status");
});

test("formatting uses the project's local binary and preserves the original tool result", async (t) => {
  const put = await project(t);
  const manifest = await put("package.json", '{"devDependencies":{"prettier":"*"}}');
  const binary = await put("node_modules/.bin/prettier", "#!/bin/sh\nexit 0\n", true);
  const file = await put("src/file with spaces.ts", "let value=1");
  let calls = 0;
  const run = setup(format, async (command, args, options) => {
    calls++;
    assert.equal(command, binary);
    assert.deepEqual(args, ["--write", file]);
    assert.equal(options?.cwd, dirname(manifest));
    assert.equal(options?.timeout, 10000);
    return success;
  });
  const content = [{ type: "text", text: "File written" }];
  const event = { toolName: "write", input: { path: "src/file with spaces.ts" }, content, isError: false };
  const result = await run("tool_result", event, dirname(manifest)) as { content: unknown[] };
  assert.deepEqual(result.content[0], content[0]);
  assert.match(JSON.stringify(result), /Read the file again/);
  await run("tool_result", { ...event, toolName: "edit" }, dirname(manifest));
  await run("tool_result", { ...event, isError: true }, dirname(manifest));
  await run("tool_result", { ...event, toolName: "read" }, dirname(manifest));
  assert.equal(calls, 2);
});

test("formatting reports failures without turning a successful write into an error", async (t) => {
  const put = await project(t);
  await put("package.json", '{"devDependencies":{"prettier":"*"}}');
  await put("node_modules/.bin/prettier", "#!/bin/sh\nexit 1\n", true);
  const file = await put("file.ts", "");
  const run = setup(format, async () => ({ ...success, code: 1, stderr: "invalid syntax" }));
  const result = await run("tool_result", {
    toolName: "edit", input: { path: file }, content: [], isError: false,
  }) as { content: { text: string }[]; isError?: boolean };
  assert.match(result.content[0].text, /invalid syntax/);
  assert.equal(result.isError, undefined);
});

test("formatter detection respects the nearest manifest and skips unsupported files", async (t) => {
  const put = await project(t);
  await put("package.json", '{"devDependencies":{"prettier":"*"}}');
  await put("node_modules/.bin/prettier", "#!/bin/sh\nexit 0\n", true);
  await put("nested/package.json", "{}");
  const file = await put("nested/file.ts", "");
  assert.equal(await findFormatter(file), undefined);
  assert.equal(await findFormatter(await put("file.png", "")), undefined);
});

test("Python projects use an installed Ruff without running a package installer", async (t) => {
  const put = await project(t);
  await put("pyproject.toml", '[dependency-groups]\ndev = ["ruff>=0.14"]\n');
  const binary = await put(".venv/bin/ruff", "#!/bin/sh\nexit 0\n", true);
  const file = await put("src/main.py", "");
  assert.deepEqual(await findFormatter(file), {
    command: binary, args: ["format", file], cwd: dirname(dirname(dirname(binary))),
  });
});

test("Nix projects use their flake formatter only when treefmt is configured", async (t) => {
  const put = await project(t);
  const flake = await put("flake.nix", "{}");
  const file = await put("modules/default.nix", "{}");
  assert.equal(await findFormatter(file), undefined);
  await put("treefmt.nix", "{}");
  assert.deepEqual(await findFormatter(file), {
    command: "nix", args: ["fmt", "--offline", "--no-write-lock-file", "--", file], cwd: dirname(flake),
  });
});

test("formatting includes the parse error when a project manifest is invalid", async (t) => {
  const put = await project(t);
  await put("package.json", "{");
  const file = await put("file.ts", "");
  const run = setup(format, async () => assert.fail("formatter must not run"));
  const result = await run("tool_result", {
    toolName: "write", input: { path: file }, content: [], isError: false,
  }) as { content: { text: string }[] };
  assert.match(result.content[0].text, /JSON/);
});

test("formatting cancellation reaches the subprocess without replacing the tool result", async (t) => {
  const put = await project(t);
  await put("package.json", '{"devDependencies":{"prettier":"*"}}');
  await put("node_modules/.bin/prettier", "#!/bin/sh\nexit 0\n", true);
  const file = await put("file.ts", "");
  const controller = new AbortController();
  const run = setup(format, async (_command, _args, options) => new Promise((resolve) => {
    options!.signal!.addEventListener("abort", () => resolve({ ...success, killed: true }), { once: true });
    controller.abort();
  }));
  const result = await run("tool_result", {
    toolName: "write", input: { path: file }, content: [], isError: false,
  }, dirname(file), controller.signal);
  assert.equal(result, undefined);
});
