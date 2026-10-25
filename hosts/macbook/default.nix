{
  pkgs,
  hostname,
  username,
  ...
}: {
  imports = [
    ../../modules/core/packages.nix
    ../../modules/core/pki.nix
    ../../modules/darwin
    ../../modules/secrets
    ../../modules/theming
  ];

  myModules = {
    theming.wallpaper = ../../assets/wallpapers/snowy-village.jpg;
    secrets.openrouterApiKey.enable = true;
  };

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
  };

  networking.hostName = hostname;

  programs = {
    zsh.enable = true;

    ssh.extraConfig = ''
      Host beans-btw kebean uribo-btw
        IdentityAgent ~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
    '';
  };

  # Loaded by /etc/zshenv for every shell (login or not, interactive or not),
  # so tools spawning a PTY without `-l` (e.g. t3code) still get a sane locale.
  environment.variables = {
    LANG = "en_US.UTF-8";
  };

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    extra-substituters = [
      "https://cache.numtide.com" # For LLM Agents
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  system = {
    stateVersion = 6;
    primaryUser = username;
    defaults = {
      dock.autohide = true;
      finder.AppleShowAllExtensions = true;
      NSGlobalDomain.AppleInterfaceStyle = "Dark";
    };
    activationScripts.aliasApplications.text = let
      aliasDir = "/Users/${username}/Applications";
      hmAppsDir = "${aliasDir}/Home Manager Apps";
    in ''
      for item in "${aliasDir}/"*.app; do
        if [ -f "$item" ] && ! [ -d "$item" ]; then
          rm -f "$item"
        fi
      done

      for app in "${hmAppsDir}/"*.app; do
        if [ -d "$app" ]; then
          ${pkgs.mkalias}/bin/mkalias "$app" "${aliasDir}/$(basename "$app")"
        fi
      done
    '';
  };

  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };
}
