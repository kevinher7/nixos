_: {
  projectRootFile = "flake.nix";

  programs.alejandra.enable = true;
  programs.statix = {
    enable = true;
    disabled-lints = ["empty_let_in" "legacy_let_syntax"];
  };

  settings = {
    formatter.alejandra = {
      excludes = ["hosts/*/hardware-configuration.nix" "*.lock"];
    };
    formatter.statix = {
      options = ["fix"];
      excludes = ["hosts/*/hardware-configuration.nix" "*.lock"];
    };
  };
}
