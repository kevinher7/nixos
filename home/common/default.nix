{
  lib,
  pkgs,
  inputs,
  username,
  osFamily,
  ...
}: {
  imports =
    [./git.nix]
    ++ lib.optional (osFamily == "linux") ./linux
    ++ lib.optional (osFamily == "darwin") ./darwin;

  programs.home-manager.enable = true;

  home = {
    inherit username;
    homeDirectory = lib.mkForce (
      if osFamily == "darwin"
      then "/Users/${username}"
      else "/home/${username}"
    );
    stateVersion = "25.11";

    packages = with pkgs; [
      btop
      tree
      gh
      curl
      pfetch
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex
    ];
  };
}
