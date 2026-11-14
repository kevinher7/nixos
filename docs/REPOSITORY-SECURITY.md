# Repository security

The GitHub repository for this configuration is `kevinher7/nixos`.
Its workflow files and Dependabot configuration live in `.github/`.
GitHub stores its repository settings separately. This checkout has no
declarative GitHub settings manager or automated settings rollout.

## Existing controls

CI pins actions to full commit SHAs and grants its token `contents: read`.
Dependabot checks GitHub Actions weekly. The flake's Git hooks include
private-key detection. These hooks run locally and in CI.
CI detects leaks only after a push.
They do not replace GitHub's secret scanning or push protection.

The live repository requires action SHA pinning, defaults workflow tokens
to read, and prevents workflows from approving pull requests. It allows
squash merges only and deletes merged branches.

The `main` ruleset requires pull requests and the `lint`, `darwin-eval`, and
`build` checks. It blocks branch deletion and force pushes. Repository
administrators can bypass this ruleset. Secret scanning and push protection
are enabled for this public repository.

## Bean Budget rollout

`kevinher7/bean-budget` remains private. Its live settings now require action
SHA pinning, allow squash merges only, and delete merged branches. Its
existing read-only workflow token default and disabled workflow pull request
approvals already matched this repository.

Bean Budget's CI and Dependabot configuration belong in its own `.github/`
directory. CI should run its existing `npm run check` on GitHub-hosted runners
with a read-only token. NixOS host builds, self-hosted runners, Cachix tokens,
and flake update credentials do not apply to Bean Budget. Android release
signing and its manual build workflow have separate ownership.

GitHub rejected rulesets and branch protection with HTTP 403 and an upgrade
requirement for the current private repository plan. CI can report failures,
but it cannot enforce a merge gate under that plan. If protection becomes
available, use Bean Budget's actual CI job names, require pull requests,
and block branch deletion and force pushes. Do not copy NixOS check names.

GitHub rejected enabling secret scanning and push protection with HTTP 422,
because those features are unavailable for this repository. Neither control
is enabled. An upgrade that permits branch protection does not by itself
establish eligibility for private secret scanning.

No secrets, environments, repository visibility, or NixOS system configuration
changed during this rollout. The live settings were verified through the
GitHub API. They take effect independently of documentation and workflow PRs.

See GitHub's documentation for [Actions settings](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository),
[ruleset availability](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets),
and [secret scanning availability](https://docs.github.com/en/code-security/reference/secret-security/secret-scanning-scope).
