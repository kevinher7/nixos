#!/usr/bin/env python3
"""
Claude Code PostToolUse hook: detect the project's formatter and run it on the
single file just written by Write/Edit.

Always exits 0 — must never block the tool action (exit 2 would).
Logs problems to stderr, prefixed with [format-on-save].
"""
from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
import tomllib
from pathlib import Path

PY_EXTS = {".py", ".pyi"}
JS_EXTS = {
    ".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs",
    ".json", ".jsonc",
    ".css", ".scss",
    ".md", ".mdx",
    ".html", ".vue", ".svelte",
    ".yml", ".yaml",
}
SUPPORTED_EXTS = PY_EXTS | JS_EXTS

# JS formatters in priority order
JS_FORMATTERS = [
    ("@biomejs/biome", "biome",    ["format", "--write"]),
    ("oxfmt",          "oxfmt",    []),
    ("prettier",       "prettier", ["--write"]),
]

SUBPROCESS_TIMEOUT_S = 10


def log(msg: str) -> None:
    print(f"[format-on-save] {msg}", file=sys.stderr)


def find_manifest(start: Path, ext: str) -> tuple[Path, str] | None:
    home = Path.home()
    want_py = ext in PY_EXTS
    want_js = ext in JS_EXTS
    for d in [start, *start.parents]:
        if want_py and (d / "pyproject.toml").is_file():
            return d, "pyproject.toml"
        if want_js and (d / "package.json").is_file():
            return d, "package.json"
        if d == home or d == d.parent:
            break
    return None


def py_dep_present(pyproject: dict, name: str) -> bool:
    name_l = name.lower()
    proj = pyproject.get("project", {}) or {}
    for dep in proj.get("dependencies", []) or []:
        if isinstance(dep, str) and dep.lower().startswith(name_l):
            return True
    for group in (proj.get("optional-dependencies", {}) or {}).values():
        for dep in group:
            if isinstance(dep, str) and dep.lower().startswith(name_l):
                return True
    for group in (pyproject.get("dependency-groups", {}) or {}).values():
        for dep in group:
            if isinstance(dep, str) and dep.lower().startswith(name_l):
                return True
    poetry = (pyproject.get("tool", {}) or {}).get("poetry", {}) or {}
    if name_l in {k.lower() for k in (poetry.get("dependencies", {}) or {})}:
        return True
    if name_l in {k.lower() for k in (poetry.get("dev-dependencies", {}) or {})}:
        return True
    for group in (poetry.get("group", {}) or {}).values():
        gdeps = group.get("dependencies", {}) or {}
        if name_l in {k.lower() for k in gdeps}:
            return True
    return False


def detect_py_runner(root: Path, pyproject: dict) -> list[str]:
    tools = pyproject.get("tool", {}) or {}
    if ((root / "uv.lock").exists() or "uv" in tools) and shutil.which("uv"):
        return ["uv", "run"]
    if ((root / "poetry.lock").exists() or "poetry" in tools) and shutil.which("poetry"):
        return ["poetry", "run"]
    return []


def detect_js_pm_exec(root: Path, pkg: dict) -> list[str]:
    pm = (pkg.get("packageManager") or "").split("@", 1)[0]
    if (pm == "bun" or (root / "bun.lock").exists() or (root / "bun.lockb").exists()) and shutil.which("bun"):
        return ["bun", "x"]
    if (pm == "pnpm" or (root / "pnpm-lock.yaml").exists()) and shutil.which("pnpm"):
        return ["pnpm", "exec"]
    if (pm == "yarn" or (root / "yarn.lock").exists()) and shutil.which("yarn"):
        return ["yarn"]
    if shutil.which("npx"):
        return ["npx", "--no-install"]
    return []


def js_dep_present(pkg: dict, name: str) -> bool:
    for key in ("devDependencies", "dependencies", "optionalDependencies"):
        if name in (pkg.get(key) or {}):
            return True
    return False


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0
    raw_path = (payload.get("tool_input") or {}).get("file_path")
    if not raw_path:
        return 0

    try:
        file_path = Path(raw_path).resolve(strict=False)
    except Exception:
        return 0
    if not file_path.exists() or not file_path.is_file():
        return 0

    ext = file_path.suffix.lower()
    if ext not in SUPPORTED_EXTS:
        return 0

    found = find_manifest(file_path.parent, ext)
    if not found:
        return 0
    project_root, manifest_kind = found

    if manifest_kind == "pyproject.toml":
        try:
            with open(project_root / "pyproject.toml", "rb") as f:
                pyproject = tomllib.load(f)
        except Exception as e:
            log(f"could not parse {project_root}/pyproject.toml: {e}")
            return 0
        ruff_configured = (
            py_dep_present(pyproject, "ruff")
            or "ruff" in (pyproject.get("tool", {}) or {})
        )
        if not ruff_configured:
            return 0
        runner = detect_py_runner(project_root, pyproject)
        cmd = [*runner, "ruff", "format", str(file_path)]
    else:
        try:
            with open(project_root / "package.json") as f:
                pkg = json.load(f)
        except Exception as e:
            log(f"could not parse {project_root}/package.json: {e}")
            return 0
        chosen = None
        for dep_key, bin_name, args in JS_FORMATTERS:
            if js_dep_present(pkg, dep_key):
                chosen = (bin_name, args)
                break
        if not chosen:
            return 0
        bin_name, args = chosen
        local_bin = project_root / "node_modules" / ".bin" / bin_name
        if local_bin.is_file() and os.access(local_bin, os.X_OK):
            cmd = [str(local_bin), *args, str(file_path)]
        else:
            pm_exec = detect_js_pm_exec(project_root, pkg)
            if not pm_exec:
                log(f"no package manager available to run {bin_name}")
                return 0
            cmd = [*pm_exec, bin_name, *args, str(file_path)]

    try:
        result = subprocess.run(
            cmd,
            cwd=project_root,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.PIPE,
            timeout=SUBPROCESS_TIMEOUT_S,
        )
        if result.returncode != 0:
            err = (result.stderr or b"").decode(errors="replace").strip().splitlines()
            first = err[0] if err else "(no stderr)"
            log(f"{cmd[0]} exit {result.returncode}: {first}")
    except subprocess.TimeoutExpired:
        log(f"timeout running {' '.join(cmd[:3])}…")
    except FileNotFoundError as e:
        log(f"binary not found: {e}")
    except Exception as e:
        log(f"unexpected error: {e}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
