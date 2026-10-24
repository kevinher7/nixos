import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Effect } from "effect";

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash" || typeof event.input.command !== "string") return;

    const command = event.input.command;
    await Effect.runPromise(
      Effect.tryPromise((signal) =>
        pi.exec("rtk", ["rewrite", "--", command], {
          cwd: ctx.cwd,
          timeout: 1000,
          signal,
        }),
      ).pipe(
        Effect.tap((result) =>
          Effect.sync(() => {
            const rewritten = result.stdout.trim();
            if (result.code === 0 && !result.killed && rewritten && !ctx.signal?.aborted) {
              event.input.command = rewritten;
            }
          }),
        ),
        Effect.catchAll(() => Effect.void),
      ),
      { signal: ctx.signal },
    ).catch(() => {});
  });
}
