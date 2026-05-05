_: {
  projectRootFile = "flake.nix";

  programs.alejandra.enable = true;
  programs.statix = {
    enable = true;
    disabled-lints = ["empty_let_in" "legacy_let_syntax"];
  };

  settings = {
    excludes = ["**/hardware-configuration.nix" "*.lock"];

    formatter.alejandra = {
    };
    formatter.statix = {
      options = ["fix"];
    };
  };
}
