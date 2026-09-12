---
description: Run linter and plan fixes
---

# Steps

Here are the current linting and formatting issues in the repository:
!`nix fmt -- --fail-on-change 2>&1 || true`

Based on the output above:

1. Categorize the issues
2. Create a prioritized plan of action to fix them
3. For any issues that are ambiguous or have multiple possible solutions (e.g., statix suggestions that might change semantics), ask the user for clarification before proceeding
4. For straightforward formatting fixes, you may proceed without asking

- If there are no issues, report that the repository is clean.
- Please keep the report simple, do not go into general details.
