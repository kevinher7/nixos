#!/usr/bin/env bash
# Wizard: rotate the repo's sops secrets, open a PR, then verify and revoke.
# Run on kebean with `nix run .#rotate-secrets`, and again with `--resume`
# after the deploy. Secret values only ever live in shell variables and pipes.
set -euo pipefail

# ──────────────────────────────────────────────────────────────────────────
# Secret table. Edit this when a module declares or drops a sops secret.
# Kinds: generated (random value made here), external (paste from a
# dashboard), manual (paste, plus a step in the service's own UI right before
# the deploy), harmonia (two-phase signing key rotation).
# ──────────────────────────────────────────────────────────────────────────

SECRET_IDS=(
  github_runner_token
  pihole_password
  cloudflare_dns_api_token
  harmonia_signing_key
  actual_server_password
  actual_http_api_key
  gmail_client_secret
  gmail_refresh_token
  t3_github_token
  openrouter_api_key@kebean
  openrouter_api_key@kebee
)

NOT_ROTATED=(mail_bean_settings_env)

declare -A FILE KIND WHAT URL HOWTO UI_STEP VERIFY REVOKE

FILE[github_runner_token]=secrets/hosts/uribo-btw.yaml
KIND[github_runner_token]=external
WHAT[github_runner_token]="Token the CI runner container registers with GitHub"
URL[github_runner_token]=https://github.com/settings/personal-access-tokens
HOWTO[github_runner_token]="Create a fine-grained PAT for kevinher7/nixos with the same repository access and permissions as the current runner token. Don't use Regenerate, so the old token works until the deploy."
VERIFY[github_runner_token]="On uribo-btw: systemctl status container@ci-runner
The runner shows Idle at https://github.com/kevinher7/nixos/settings/actions/runners"
REVOKE[github_runner_token]="Delete the old runner PAT at https://github.com/settings/personal-access-tokens"

FILE[pihole_password]=secrets/hosts/uribo-btw.yaml
KIND[pihole_password]=external
WHAT[pihole_password]="Pi-hole web admin password hash, written to webserver.api.pwhash"
URL[pihole_password]=https://pihole.beanhaven.net
HOWTO[pihole_password]="This secret is the pwhash, not the password. Save a new password in Vaultwarden, set it on a scratch Pi-hole v6 with 'pihole setpassword', and paste webserver.api.pwhash from its pihole.toml."
VERIFY[pihole_password]="Log in at https://pihole.beanhaven.net with the new password"

FILE[cloudflare_dns_api_token]=secrets/hosts/uribo-btw.yaml
KIND[cloudflare_dns_api_token]=external
WHAT[cloudflare_dns_api_token]="Cloudflare token ACME uses for DNS-01 challenges"
URL[cloudflare_dns_api_token]=https://dash.cloudflare.com/profile/api-tokens
HOWTO[cloudflare_dns_api_token]="Create a new token with Zone / Zone / Read and Zone / DNS / Edit on beanhaven.net. Don't use Roll on the old one."
VERIFY[cloudflare_dns_api_token]="On uribo-btw, prints active: sudo sed 's/^/Authorization: Bearer /' /run/secrets/cloudflare_dns_api_token | curl -sS -H @- https://api.cloudflare.com/client/v4/user/tokens/verify | jq -r .result.status
On uribo-btw: sudo systemctl start acme-order-renew-beanhaven.net.service && journalctl -u acme-order-renew-beanhaven.net -n 20"
REVOKE[cloudflare_dns_api_token]="Delete the old token at https://dash.cloudflare.com/profile/api-tokens"

FILE[harmonia_signing_key]=secrets/hosts/uribo-btw.yaml
KIND[harmonia_signing_key]=harmonia
WHAT[harmonia_signing_key]="Key Harmonia signs cache.beanhaven.net paths with"
VERIFY[harmonia_signing_key]="On kebean, lists a Sig for every cache.beanhaven.net key Nix trusts: curl -s https://cache.beanhaven.net/\$(readlink /run/current-system | cut -c12-43).narinfo | grep Sig
On kebean: nix config show trusted-public-keys"

FILE[actual_server_password]=secrets/hosts/uribo-btw.yaml
KIND[actual_server_password]=manual
WHAT[actual_server_password]="Actual server password, used by actual-http-api and mail-bean"
URL[actual_server_password]=https://budget.beanhaven.net
HOWTO[actual_server_password]="Generate a new password in Vaultwarden and save it there. Don't change it in Actual yet."
UI_STEP[actual_server_password]="Right before fleet-deploy, change the server password in Actual (https://budget.beanhaven.net, Settings) to the new one from Vaultwarden. actual-http-api and mail-bean can't log in until the deploy finishes."
VERIFY[actual_server_password]="Log in at https://budget.beanhaven.net with the new password
On uribo-btw: sudo systemctl start mail-bean && journalctl -u mail-bean -n 20
On uribo-btw, prints 200: sudo sed 's/^/x-api-key: /' /run/secrets/actual_http_api_key | curl -sS -o /dev/null -w '%{http_code}\n' -H @- https://actual-api.beanhaven.net/v1/budgets/d90c6528-ee2f-49e4-b5d1-5019b5136b1e/accounts"

FILE[actual_http_api_key]=secrets/hosts/uribo-btw.yaml
KIND[actual_http_api_key]=generated
WHAT[actual_http_api_key]="API key clients send to actual-http-api as x-api-key"
VERIFY[actual_http_api_key]="On uribo-btw, prints 200: sudo sed 's/^/x-api-key: /' /run/secrets/actual_http_api_key | curl -sS -o /dev/null -w '%{http_code}\n' -H @- https://actual-api.beanhaven.net/v1/budgets/d90c6528-ee2f-49e4-b5d1-5019b5136b1e/accounts
Give the new key to every client of actual-api. Read it on uribo-btw with: sudo cat /run/secrets/actual_http_api_key"

FILE[gmail_client_secret]=secrets/hosts/uribo-btw.yaml
KIND[gmail_client_secret]=external
WHAT[gmail_client_secret]="OAuth client secret mail-bean uses for the Gmail API"
URL[gmail_client_secret]=https://console.cloud.google.com/auth/clients
HOWTO[gmail_client_secret]="Open mail-bean's OAuth client and use Add secret. Leave the old secret enabled until the deploy is verified."
VERIFY[gmail_client_secret]="On uribo-btw: sudo systemctl start mail-bean && journalctl -u mail-bean -n 20"
REVOKE[gmail_client_secret]="Disable, then delete, the old secret on mail-bean's OAuth client at https://console.cloud.google.com/auth/clients"

FILE[gmail_refresh_token]=secrets/hosts/uribo-btw.yaml
KIND[gmail_refresh_token]=external
WHAT[gmail_refresh_token]="Gmail OAuth refresh token mail-bean reads mail with"
URL[gmail_refresh_token]=https://developers.google.com/oauthplayground
HOWTO[gmail_refresh_token]="In the playground settings, tick 'Use your own OAuth credentials' with mail-bean's client ID and current secret, authorize https://www.googleapis.com/auth/gmail.modify, exchange the code and copy the refresh token."
VERIFY[gmail_refresh_token]="On uribo-btw: sudo systemctl start mail-bean && journalctl -u mail-bean -n 20"
REVOKE[gmail_refresh_token]="Revoke the old refresh token by POSTing it to https://oauth2.googleapis.com/revoke (decrypt it from the commit before the rotation). Don't remove the app under your Google account's third-party connections, that revokes the new token too."

FILE[t3_github_token]=secrets/common/t3code.yaml
KIND[t3_github_token]=external
WHAT[t3_github_token]="GitHub token (GH_TOKEN) the T3 Code servers use"
URL[t3_github_token]=https://github.com/settings/personal-access-tokens
HOWTO[t3_github_token]="Create a fine-grained PAT with the same repo and permissions; don't use Regenerate."
VERIFY[t3_github_token]="On uribo-btw and kebean, prints your login: sudo sed 's/^GH_TOKEN=/Authorization: Bearer /' /run/secrets/rendered/t3code-github.env | curl -sS -H @- https://api.github.com/user | jq -r .login"
REVOKE[t3_github_token]="Delete the old T3 Code PAT at https://github.com/settings/personal-access-tokens"

FILE[openrouter_api_key@kebean]=secrets/hosts/kebean.yaml
KIND[openrouter_api_key@kebean]=external
WHAT[openrouter_api_key@kebean]="OpenRouter key pi uses on kebean"
URL[openrouter_api_key@kebean]=https://openrouter.ai/settings/keys
HOWTO[openrouter_api_key@kebean]="Create a new key. Keep the old one until the deploy is verified."
VERIFY[openrouter_api_key@kebean]="On kebean, prints the key's label: sed 's/^/Authorization: Bearer /' /run/secrets/openrouter_api_key | curl -sS -H @- https://openrouter.ai/api/v1/key | jq -r .data.label"
REVOKE[openrouter_api_key@kebean]="Delete kebean's old key at https://openrouter.ai/settings/keys"

FILE[openrouter_api_key@kebee]=secrets/hosts/kebee.yaml
KIND[openrouter_api_key@kebee]=external
WHAT[openrouter_api_key@kebee]="OpenRouter key pi uses on the macbook"
URL[openrouter_api_key@kebee]=https://openrouter.ai/settings/keys
HOWTO[openrouter_api_key@kebee]="Create a new key. Keep the old one until the deploy is verified."
VERIFY[openrouter_api_key@kebee]="On kebee, prints the key's label: sed 's/^/Authorization: Bearer /' /run/secrets/openrouter_api_key | curl -sS -H @- https://openrouter.ai/api/v1/key | jq -r .data.label"
REVOKE[openrouter_api_key@kebee]="Delete the macbook's old key at https://openrouter.ai/settings/keys"

NIXOS_HOSTS=(uribo-btw kebean beans-btw)
DARWIN_HOSTS=(kebee)
HARMONIA_KEYS_NIX=modules/system/default.nix
HARMONIA_NEXT_SECRET=harmonia_signing_key_next
HARMONIA_KEY_PREFIX=cache.beanhaven.net
NIX=(nix --extra-experimental-features "nix-command flakes")

# ──────────────────────────────────────────────────────────────────────────
# Output helpers, same look as fleet-deploy.
# ──────────────────────────────────────────────────────────────────────────

if [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]; then
  BOLD=$(tput bold); DIM=$(tput dim); RESET=$(tput sgr0)
  BLUE=$(tput setaf 4); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3)
else
  BOLD=""; DIM=""; RESET=""; BLUE=""; GREEN=""; YELLOW=""
fi

TOTAL_STAGES=0
_STAGE_INDEX=0

_clear() {
  [[ -t 1 ]] || return 0
  if command -v tput >/dev/null 2>&1 && tput clear 2>/dev/null; then return 0; fi
  printf '\033[2J\033[3J\033[H'
}

banner() {
  _clear
  printf '\n%s%s  %s%s\n' "$BOLD" "$BLUE" "$1" "$RESET"
  printf '%s  %s stages%s\n\n' "$DIM" "$TOTAL_STAGES" "$RESET"
}

stage() {
  _STAGE_INDEX=$((_STAGE_INDEX + 1))
  printf '\n%s%s▸ Stage %s/%s · %s%s\n' \
    "$BOLD" "$BLUE" "$_STAGE_INDEX" "$TOTAL_STAGES" "$1" "$RESET"
}

say()  { printf '  %s\n' "$1"; }
step() { printf '  %s•%s %s\n' "$BLUE" "$RESET" "$1"; }
note() { printf '  %s%s%s\n' "$DIM" "$1" "$RESET"; }
warn() { printf '  %s⚠ %s%s\n' "$YELLOW" "$1" "$RESET"; }
ok()   { printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$1"; }
die()  { printf '  %s✗ %s%s\n' "$YELLOW" "$1" "$RESET" >&2; exit 1; }

lines() {
  local line
  while IFS= read -r line; do
    if [[ -n "$line" ]]; then
      step "$line"
    fi
  done <<< "$1"
}

ask() { gum confirm --default=false "$1"; }

# ──────────────────────────────────────────────────────────────────────────
# Setup
# ──────────────────────────────────────────────────────────────────────────

usage() {
  cat <<EOF
Usage: rotate-secrets [--no-push] [secret...]
       rotate-secrets --resume

Rotates the selected sops secrets, commits them on a new branch and opens a
PR. After merging and deploying, --resume walks through verification and
revoking the old values. --no-push commits locally without pushing or
opening a PR. ROTATE_SECRETS_REPO points it at another checkout.

Secrets: ${SECRET_IDS[*]}
EOF
}

RESUME=0
PUSH=1
PICKS=()
while (($#)); do
  case "$1" in
    --resume) RESUME=1 ;;
    --no-push) PUSH=0 ;;
    -h | --help) usage; exit 0 ;;
    -*) usage >&2; exit 1 ;;
    *) PICKS+=("$1") ;;
  esac
  shift
done

REPO=${ROTATE_SECRETS_REPO:-$(git rev-parse --show-toplevel)}
cd "$REPO"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/rotate-secrets"
RUN_FILE="$STATE_DIR/run"
ROTATED_FILE="$STATE_DIR/rotated"
CHECKED_FILE="$STATE_DIR/checked"
mkdir -p "$STATE_DIR"

state_get() {
  [[ -f "$RUN_FILE" ]] || return 0
  sed -n "s/^$1=//p" "$RUN_FILE" | tail -n1
}

state_set() {
  printf '%s=%s\n' "$1" "$2" >> "$RUN_FILE"
}

is_checked() {
  [[ -f "$CHECKED_FILE" ]] && grep -qx "$1 $2" "$CHECKED_FILE"
}

archive_state() {
  local dest
  dest="$STATE_DIR/done/$(date +%Y%m%dT%H%M%S)"
  mkdir -p "$dest"
  mv "$RUN_FILE" "$ROTATED_FILE" "$dest"/
  if [[ -f "$CHECKED_FILE" ]]; then
    mv "$CHECKED_FILE" "$dest"/
  fi
  note "State moved to $dest"
}

name_of() { printf '%s' "${1%@*}"; }

secret_exists() {
  grep -q "^$2:" "$1"
}

harmonia_phase() {
  if secret_exists "${FILE[harmonia_signing_key]}" "$HARMONIA_NEXT_SECRET"; then
    printf 2
  else
    printf 1
  fi
}

label() {
  local id="$1" extra=""
  if [[ "${KIND[$id]}" == harmonia ]]; then
    extra=" (phase $(harmonia_phase))"
  fi
  printf '%s  %s%s' "$id" "${FILE[$id]}" "$extra"
}

sops_set() {
  jq -Rs . | sops set --value-stdin "$1" "[\"$2\"]"
}

# ──────────────────────────────────────────────────────────────────────────
# Drift check: the table against the secrets each host declares.
# ──────────────────────────────────────────────────────────────────────────

declared_secrets() {
  "${NIX[@]}" eval --json "$REPO#$1.config.sops.secrets" \
    --apply 's: map (n: n + " " + baseNameOf (toString (builtins.getAttr n s).sopsFile)) (builtins.attrNames s)' |
    jq -r '.[]'
}

drift_check() {
  local host attr out declared=() line name base id found missing=0
  say "Comparing the table with the secrets each host declares."
  for host in "${NIXOS_HOSTS[@]}" "${DARWIN_HOSTS[@]}"; do
    attr="nixosConfigurations.$host"
    if printf '%s\n' "${DARWIN_HOSTS[@]}" | grep -qx "$host"; then
      attr="darwinConfigurations.$host"
    fi
    if out=$(declared_secrets "$attr" 2>/dev/null) && [[ -n "$out" ]]; then
      mapfile -t -O "${#declared[@]}" declared <<< "$out"
    else
      warn "could not evaluate $host, skipping it in the drift check"
      missing=1
    fi
  done

  for line in "${declared[@]}"; do
    name="${line% *}"
    base="${line#* }"
    [[ "$name" == "$HARMONIA_NEXT_SECRET" ]] && continue
    printf '%s\n' "${NOT_ROTATED[@]}" | grep -qx "$name" && continue
    found=0
    for id in "${SECRET_IDS[@]}"; do
      if [[ "$(name_of "$id")" == "$name" && "$(basename "${FILE[$id]}")" == "$base" ]]; then
        found=1
      fi
    done
    if ((!found)); then
      warn "$name ($base) is declared but missing from the secret table"
      missing=1
    fi
  done

  for id in "${SECRET_IDS[@]}"; do
    if ! printf '%s\n' "${declared[@]}" | sort -u | grep -qx "$(name_of "$id") $(basename "${FILE[$id]}")"; then
      warn "$id is in the table but no host declares it"
      missing=1
    fi
  done

  if ((!missing)); then
    ok "table matches the declared secrets"
  fi
}

# ──────────────────────────────────────────────────────────────────────────
# Rotation per kind. Values stay in locals and pipes and are unset after use.
# ──────────────────────────────────────────────────────────────────────────

ROTATED=()
CHANGED_FILES=()
NIX_EDITS=()
DEPLOY_STEPS=()
HAS_HARMONIA_PHASE1=0

record_rotation() {
  local id="$1" phase="$2"
  ROTATED+=("$id")
  printf '%s\n' "${CHANGED_FILES[@]}" | grep -qx "${FILE[$id]}" || CHANGED_FILES+=("${FILE[$id]}")
  printf '%s %s %s\n' "$id" "$phase" "$(date -Iseconds)" >> "$ROTATED_FILE"
  ok "stored $(name_of "$id") in ${FILE[$id]}"
}

store_pasted() {
  local id="$1" value=""
  IFS= read -rs -p "  ${BOLD}Paste the new value (hidden), or press Enter to skip:${RESET} " value || true
  printf '\n'
  if [[ -z "$value" ]]; then
    warn "no value, skipping $id"
    return
  fi
  if printf '%s' "$value" | sops_set "${FILE[$id]}" "$(name_of "$id")"; then
    unset value
    record_rotation "$id" -
  else
    unset value
    warn "sops could not write $id, skipping it"
  fi
}

rotate_generated() {
  local id="$1" value
  value=$(openssl rand -base64 32)
  if printf '%s' "$value" | sops_set "${FILE[$id]}" "$(name_of "$id")"; then
    unset value
    record_rotation "$id" -
  else
    unset value
    warn "sops could not write $id, skipping it"
  fi
}

rotate_external() {
  local id="$1"
  step "Open ${URL[$id]}"
  step "${HOWTO[$id]}"
  store_pasted "$id"
}

rotate_manual() {
  local id="$1"
  step "Open ${URL[$id]}"
  step "${HOWTO[$id]}"
  note "Later: ${UI_STEP[$id]}"
  store_pasted "$id"
  if [[ " ${ROTATED[*]} " == *" $id "* ]]; then
    DEPLOY_STEPS+=("${UI_STEP[$id]}")
  fi
}

current_key_number() {
  grep -oE "current = \"${HARMONIA_KEY_PREFIX//./\\.}-[0-9]+:" "$HARMONIA_KEYS_NIX" | grep -oE '[0-9]+' | tail -n1
}

rotate_harmonia_phase1() {
  local id="$1" file="${FILE[$1]}" current key_name secret public
  current=$(current_key_number) || true
  if [[ -z "$current" ]]; then
    warn "no current $HARMONIA_KEY_PREFIX key in $HARMONIA_KEYS_NIX, skipping $id"
    return
  fi
  key_name="$HARMONIA_KEY_PREFIX-$((current + 1))"
  say "Phase 1: generate $key_name and sign with it next to the current key."
  secret=$("${NIX[@]}" key generate-secret --key-name "$key_name")
  if ! printf '%s' "$secret" | sops_set "$file" "$HARMONIA_NEXT_SECRET"; then
    unset secret
    warn "sops could not write $HARMONIA_NEXT_SECRET, skipping it"
    return
  fi
  public=$(printf '%s' "$secret" | "${NIX[@]}" key convert-secret-to-public)
  unset secret
  record_rotation "$id" 1
  say "Public key: $public"
  NIX_EDITS+=("In $HARMONIA_KEYS_NIX set myVars.harmoniaPublicKeys.next = \"$public\"; (this also enables myHomelab.harmonia.nextKey)")
  HAS_HARMONIA_PHASE1=1
}

rotate_harmonia_phase2() {
  local id="$1" file="${FILE[$1]}" value
  say "Phase 2: promote $HARMONIA_NEXT_SECRET to harmonia_signing_key."
  if grep -qE '^\s*next = null;' "$HARMONIA_KEYS_NIX"; then
    warn "myVars.harmoniaPublicKeys.next is null, so phase 1 never reached main"
    ask "Promote the next key anyway?" || return 0
  fi
  ask "Is every NixOS host deployed with the phase 1 config (trusting the next key)?" || {
    warn "skipping $id until phase 1 is deployed everywhere"
    return 0
  }
  if ! value=$(sops decrypt --extract "[\"$HARMONIA_NEXT_SECRET\"]" "$file"); then
    unset value
    warn "sops could not read $HARMONIA_NEXT_SECRET, skipping it"
    return
  fi
  if ! printf '%s' "$value" | sops_set "$file" "$(name_of "$id")"; then
    unset value
    warn "sops could not write $id, skipping it"
    return
  fi
  unset value
  if ! sops unset "$file" "[\"$HARMONIA_NEXT_SECRET\"]"; then
    warn "harmonia_signing_key holds the next key now, but sops could not remove $HARMONIA_NEXT_SECRET; rerun to finish"
    return
  fi
  record_rotation "$id" 2
  NIX_EDITS+=("In $HARMONIA_KEYS_NIX move the next public key to myVars.harmoniaPublicKeys.current and set next = null;")
}

rotate() {
  local id="$1"
  printf '\n  %s%s%s  %s%s%s\n' "$BOLD" "$(name_of "$id")" "$RESET" "$DIM" "${FILE[$id]}" "$RESET"
  note "${WHAT[$id]}"
  case "${KIND[$id]}" in
    generated) rotate_generated "$id" ;;
    external) rotate_external "$id" ;;
    manual) rotate_manual "$id" ;;
    harmonia)
      if [[ "$(harmonia_phase)" == 1 ]]; then
        rotate_harmonia_phase1 "$id"
      else
        rotate_harmonia_phase2 "$id"
      fi
      ;;
  esac
}

# ──────────────────────────────────────────────────────────────────────────
# Flows
# ──────────────────────────────────────────────────────────────────────────

rotate_flow() {
  [[ -n "${SOPS_AGE_KEY_CMD:-}" ]] ||
    die "SOPS_AGE_KEY_CMD is not set. Run this on kebean, where home/programs/sops.nix sets it to decrypt the admin key."
  [[ -z "$(git status --porcelain --untracked-files=no)" ]] ||
    die "the working tree has uncommitted changes"
  if ((PUSH)); then
    git fetch -q origin main
    [[ "$(git rev-parse HEAD)" == "$(git rev-parse origin/main)" ]] ||
      die "check out an up to date main first (HEAD is not origin/main)"
  fi
  if [[ -f "$RUN_FILE" ]]; then
    warn "a previous rotation on $(state_get branch) is not finished"
    if ask "Finish it with --resume instead?"; then
      exec "$0" --resume
    fi
    archive_state
  fi

  TOTAL_STAGES=4
  banner "Rotate secrets"

  stage "Pick secrets"
  drift_check
  local id picks=() labels=()
  if ((${#PICKS[@]})); then
    for id in "${PICKS[@]}"; do
      [[ -n "${KIND[$id]:-}" ]] || die "unknown secret '$id'"
    done
    picks=("${PICKS[@]}")
  else
    for id in "${SECRET_IDS[@]}"; do labels+=("$(label "$id")"); done
    note "Arrows move, x or tab toggles, enter confirms."
    mapfile -t picks < <(printf '%s\n' "${labels[@]}" |
      gum choose --no-limit --selected '*' --height "$((${#labels[@]} + 1))" \
        --header "Secrets to rotate" | cut -d' ' -f1)
  fi
  ((${#picks[@]})) || die "nothing selected"

  local branch started
  started=$(date -Iseconds)
  : > "$ROTATED_FILE"
  rm -f "$CHECKED_FILE"
  state_set started "$started"

  stage "Rotate"
  say "Each value goes straight from memory into sops. sops may ask for the admin key's passphrase each time."
  for id in "${picks[@]}"; do
    rotate "$id"
  done

  if ((${#ROTATED[@]} == 0)); then
    rm -f "$RUN_FILE" "$ROTATED_FILE"
    die "nothing was rotated"
  fi

  stage "Commit and open a PR"
  branch="chore/rotate-secrets-$(date +%F)"
  if git rev-parse -q --verify "refs/heads/$branch" >/dev/null; then
    branch="$branch-$(date +%H%M%S)"
  fi
  git switch -q -c "$branch"
  state_set branch "$branch"

  local names=() title body
  for id in "${ROTATED[@]}"; do names+=("$(name_of "$id")"); done
  title="chore(secrets): rotate $(printf '%s\n' "${names[@]}" | sort -u | paste -sd, - | sed 's/,/, /g')"
  body="Rotated with \`nix run .#rotate-secrets\`:"$'\n'
  for id in "${ROTATED[@]}"; do body+=$'\n'"- \`$(name_of "$id")\` in \`${FILE[$id]}\`"; done
  if ((${#NIX_EDITS[@]})); then
    body+=$'\n\n'"Nix edits to push to this branch before merging:"$'\n'
    for line in "${NIX_EDITS[@]}"; do body+=$'\n'"- $line"; done
  fi
  if ((${#DEPLOY_STEPS[@]})); then
    body+=$'\n\n'"Before the deploy:"$'\n'
    for line in "${DEPLOY_STEPS[@]}"; do body+=$'\n'"- $line"; done
  fi

  git add -- "${CHANGED_FILES[@]}"
  git commit -q -m "$title" -m "$body" -- "${CHANGED_FILES[@]}"
  ok "committed $(git rev-parse --short HEAD) on $branch"

  if ((PUSH)); then
    git push -q -u origin "$branch"
    local draft=() pr
    if ((${#NIX_EDITS[@]})); then
      draft=(--draft)
    fi
    pr=$(gh pr create --base main --head "$branch" --title "$title" --body "$body" "${draft[@]}")
    state_set pr "$pr"
    ok "opened $pr"
  else
    note "--no-push: left $branch local, no PR"
  fi

  stage "Deploy"
  if ((${#NIX_EDITS[@]})); then
    warn "Push these Nix edits to $branch before merging:"
    for line in "${NIX_EDITS[@]}"; do step "$line"; done
  fi
  if ((HAS_HARMONIA_PHASE1)); then
    note "After phase 1 is deployed everywhere, run the wizard again for harmonia_signing_key to promote the key."
  fi
  for line in "${DEPLOY_STEPS[@]}"; do step "$line"; done
  say "Merge and run fleet-deploy when CI on main is idle, then rerun with --resume."
}

resume_flow() {
  [[ -f "$RUN_FILE" && -s "$ROTATED_FILE" ]] || die "no rotation in progress under $STATE_DIR"
  TOTAL_STAGES=2
  banner "Rotate secrets: verify and revoke"
  note "Branch $(state_get branch), started $(state_get started)"

  local id phase _ text pending=0
  stage "Verify"
  while read -r -u 3 id phase _; do
    if is_checked verified "$id"; then
      ok "$id verified earlier"
      continue
    fi
    printf '\n  %s%s%s\n' "$BOLD" "$(name_of "$id")" "$RESET"
    lines "${VERIFY[$id]:-}"
    if [[ "${KIND[$id]}" == harmonia && "$phase" == 1 ]]; then
      step "Expect signatures from both the current and the next key."
    elif [[ "${KIND[$id]}" == harmonia ]]; then
      step "Expect only the new key's signature, and only it in the trusted keys."
    fi
    if ask "Does $(name_of "$id") work with the new value?"; then
      printf 'verified %s\n' "$id" >> "$CHECKED_FILE"
    else
      warn "fix $id before revoking the old value, then rerun --resume"
      pending=1
    fi
  done 3< "$ROTATED_FILE"

  stage "Revoke"
  while read -r -u 3 id phase _; do
    if is_checked revoked "$id"; then
      ok "$id done earlier"
      continue
    fi
    if ! is_checked verified "$id"; then
      pending=1
      continue
    fi
    text="${REVOKE[$id]:-}"
    if [[ "${KIND[$id]}" == harmonia && "$phase" == 1 ]]; then
      text="Run the wizard again and pick harmonia_signing_key to promote the next key (phase 2)."
    fi
    if [[ -n "$text" ]]; then
      printf '\n  %s%s%s\n' "$BOLD" "$(name_of "$id")" "$RESET"
      step "$text"
      if ! ask "Done?"; then
        pending=1
        continue
      fi
    fi
    printf 'revoked %s\n' "$id" >> "$CHECKED_FILE"
  done 3< "$ROTATED_FILE"

  printf '\n'
  if ((pending)); then
    warn "some items are still open; rerun with --resume"
  else
    ok "rotation complete"
    archive_state
  fi
}

if ((RESUME)); then
  resume_flow
else
  rotate_flow
fi
