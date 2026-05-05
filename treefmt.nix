_: {
  projectRootFile = "flake.nix";

  programs.alejandra.enable = true;
  programs.statix.enable = true;

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
