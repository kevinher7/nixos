{...}: {
  imports = [
    ./homebrew.nix
    ./secretive.nix
  ];

  security.pam.services.sudo_local.touchIdAuth = true;

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };

    optimise.automatic = true;
  };
}
