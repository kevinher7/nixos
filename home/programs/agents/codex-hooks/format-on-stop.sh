#!/usr/bin/env bash
set -uo pipefail

json_escape() {
  local s=${1-}
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  s=${s//$'\n'/\\n}
  s=${s//$'\r'/\\r}
  s=${s//$'\t'/\\t}
  printf '%s' "$s"
}

json_success() {
  local message=${1-}
  if [[ -n "$message" ]]; then
    printf '{"continue":true,"systemMessage":"%s"}\n' "$(json_escape "$message")"
  else
    printf '{"continue":true}\n'
  fi
}

json_block() {
  local reason=${1-}
  printf '{"decision":"block","reason":"%s"}\n' "$(json_escape "$reason")"
}

trim_output() {
  local text=${1-}
  local limit=${2:-3000}
  if (( ${#text} <= limit )); then
    printf '%s' "$text"
    return
  fi
  printf '%s\n\n[output truncated]' "${text:0:limit-20}"
}

read_json_field() {
  local payload=$1
  local expr=$2
  jq -er "$expr" <<<"$payload" 2>/dev/null
}

chunk_and_run() {
  shift
  local -a base_command=()
  while [[ $# -gt 0 && "$1" != "--" ]]; do
    base_command+=("$1")
    shift
  done
  shift

  local -a files=("$@")
  local total=${#files[@]}
  local batch_size=100
  local start=0
  local output=""
  local status=0

  while (( start < total )); do
    local -a batch=("${files[@]:start:batch_size}")
    local -a command=("${base_command[@]}" "${batch[@]}")
    local rendered
    rendered=$(printf '%q ' "${command[@]}")
    rendered=${rendered% }

    local cmd_output
    cmd_output=$(cd "$REPO_ROOT" && "${command[@]}" 2>&1)
    status=$?

    output+='$ '
    output+="$rendered"
    output+=$'\n'"exit=$status"
    if [[ -n "$cmd_output" ]]; then
      output+=$'\n'"$cmd_output"
    fi
    output+=$'\n\n'

    if (( status != 0 )); then
      LAST_COMMAND_OUTPUT=${output%$'\n\n'}
      return "$status"
    fi

    ((start+=batch_size))
  done

  LAST_COMMAND_OUTPUT=${output%$'\n\n'}
  return 0
}

if ! command -v jq >/dev/null 2>&1; then
  json_success "Auto-format hook skipped: jq is required for hook payload parsing but was not found on PATH."
  exit 0
fi

PAYLOAD=$(cat)
if [[ -z "$PAYLOAD" ]]; then
  json_success
  exit 0
fi

STOP_HOOK_ACTIVE=$(read_json_field "$PAYLOAD" '.stop_hook_active // false' || printf 'false')
if [[ "$STOP_HOOK_ACTIVE" == "true" ]]; then
  json_success
  exit 0
fi

CWD=$(read_json_field "$PAYLOAD" '.cwd // empty' || true)
if [[ -z "$CWD" ]]; then
  json_success
  exit 0
fi

if REPO_ROOT=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null); then
  :
else
  REPO_ROOT=$(cd "$CWD" 2>/dev/null && pwd -P) || {
    json_success
    exit 0
  }
fi

DIFF_FILES=()
while IFS= read -r line; do
  [[ -n "$line" ]] || continue
  DIFF_FILES+=("$line")
done < <(git -C "$REPO_ROOT" diff --name-only)

if (( ${#DIFF_FILES[@]} == 0 )); then
  json_success
  exit 0
fi

PYPROJECT_PATH="$REPO_ROOT/pyproject.toml"
PACKAGE_JSON_PATH="$REPO_ROOT/package.json"
UV_LOCK_PATH="$REPO_ROOT/uv.lock"
POETRY_LOCK_PATH="$REPO_ROOT/poetry.lock"

HAS_PYPROJECT=false
HAS_PACKAGE_JSON=false
[[ -f "$PYPROJECT_PATH" ]] && HAS_PYPROJECT=true
[[ -f "$PACKAGE_JSON_PATH" ]] && HAS_PACKAGE_JSON=true

PYPROJECT_TEXT=""
if [[ -f "$PYPROJECT_PATH" ]]; then
  PYPROJECT_TEXT=$(cat "$PYPROJECT_PATH" 2>/dev/null || true)
fi

CHANGED_FILES=()
for rel in "${DIFF_FILES[@]}"; do
  [[ -f "$REPO_ROOT/$rel" ]] || continue
  CHANGED_FILES+=("$rel")
done

if (( ${#CHANGED_FILES[@]} == 0 )); then
  json_success
  exit 0
fi

PY_FILES=()
PRETTIER_FILES=()
for rel in "${CHANGED_FILES[@]}"; do
  case "$rel" in
    *.py|*.pyi)
      PY_FILES+=("$rel")
      ;;
  esac

  case "$rel" in
    *.cjs|*.css|*.html|*.js|*.json|*.jsonc|*.jsx|*.md|*.mdx|*.mjs|*.scss|*.ts|*.tsx|*.yaml|*.yml)
      PRETTIER_FILES+=("$rel")
      ;;
  esac
done

NOTES=()
COMMANDS_RUN=()
LAST_COMMAND_OUTPUT=""

PY_LABEL=""
PY_RUNNER=()
if [[ "$HAS_PYPROJECT" == true ]]; then
  if [[ -f "$UV_LOCK_PATH" || "$PYPROJECT_TEXT" == *"[tool.uv"* ]]; then
    PY_LABEL="uv run ruff format --fix"
    PY_RUNNER=(uv run ruff format)
  elif [[ -f "$POETRY_LOCK_PATH" || "$PYPROJECT_TEXT" == *"[tool.poetry]"* ]]; then
    PY_LABEL="poetry run ruff format --fix"
    PY_RUNNER=(poetry run ruff format)
  fi
fi

if (( ${#PY_RUNNER[@]} > 0 && ${#PY_FILES[@]} > 0 )); then
  if ! chunk_and_run "$PY_LABEL" "${PY_RUNNER[@]}" -- "${PY_FILES[@]}"; then
    json_block "Auto-format hook failed while running ${PY_LABEL} on changed files.\n\n$(trim_output "$LAST_COMMAND_OUTPUT")"
    exit 0
  fi
  COMMANDS_RUN+=("${PY_LABEL} (${#PY_FILES[@]} files)")
fi

if [[ "$HAS_PACKAGE_JSON" == true ]]; then
  PRETTIER_LABEL="npx --no-install prettier --write"
  PRETTIER_RUNNER=(npx --no-install prettier --write)

  if (( ${#PRETTIER_FILES[@]} > 0 )) && ! chunk_and_run "$PRETTIER_LABEL" "${PRETTIER_RUNNER[@]}" -- "${PRETTIER_FILES[@]}"; then
    json_block "Auto-format hook failed while running ${PRETTIER_LABEL} on changed files.\n\n$(trim_output "$LAST_COMMAND_OUTPUT")"
    exit 0
  fi
  if (( ${#PRETTIER_FILES[@]} > 0 )); then
    COMMANDS_RUN+=("${PRETTIER_LABEL} (${#PRETTIER_FILES[@]} files)")
  fi
fi

if (( ${#COMMANDS_RUN[@]} == 0 )) && (( ${#PY_RUNNER[@]} == 0 )) && [[ "$HAS_PACKAGE_JSON" != true ]]; then
  NOTES+=("Auto-format hook skipped: no supported formatter setup was found at the repo root.")
fi

if (( ${#COMMANDS_RUN[@]} > 0 )); then
  SUMMARY="Auto-format hook ran: $(IFS='; '; printf '%s' "${COMMANDS_RUN[*]}")"
  if (( ${#NOTES[@]} > 0 )); then
    SUMMARY+=". $(IFS=' '; printf '%s' "${NOTES[*]}")"
  fi
  json_success "$SUMMARY"
  exit 0
fi

if (( ${#NOTES[@]} > 0 )); then
  json_success "$(IFS=' '; printf '%s' "${NOTES[*]}")"
  exit 0
fi

json_success
