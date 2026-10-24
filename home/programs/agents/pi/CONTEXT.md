# Pi extensions

Bash commands pass through `rtk rewrite`. Unsupported commands run unchanged.
Use `rtk proxy <command>` when you need unfiltered output. Use Pi's read tool
for source files.

Successful write and edit calls run the project's configured formatter when
available. Read the file again after formatting before making another edit.
Do not run formatters again unless the hook reports a failure.
