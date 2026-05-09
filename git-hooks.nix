{pkgs, ...}: {
  hooks = {
    alejandra = {
      enable = true;
      excludes = ["hardware-configuration\\.nix$"];
    };
    statix.enable = true;

    check-yaml = {
      enable = true;
      name = "Check YAML";
      entry = "${pkgs.python3Packages.pre-commit-hooks}/bin/check-yaml";
      types = ["yaml"];
    };

    trailing-whitespace = {
      enable = true;
      name = "Trailing Whitespace";
      entry = "${pkgs.python3Packages.pre-commit-hooks}/bin/trailing-whitespace-fixer";
      types = ["text"];
    };

    detect-private-key = {
      enable = true;
      name = "Detect Private Key";
      entry = "${pkgs.python3Packages.pre-commit-hooks}/bin/detect-private-key";
    };

    conventional-commits = {
      enable = true;
      name = "Conventional Commits";
      entry = toString (pkgs.writeShellScript "check-conventional-commit" ''
        set -e
        msg=$(cat "$1")
        regex="^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?!?: .+"
        if echo "$msg" | grep -qE "$regex"; then
          exit 0
        fi
        echo "ERROR: Commit message does not follow Conventional Commits."
        echo "Expected format: <type>[optional scope]: <description>"
        echo "Allowed types: feat, fix, docs, style, refactor, test, chore"
        exit 1
      '');
      stages = ["commit-msg"];
    };
  };
}
