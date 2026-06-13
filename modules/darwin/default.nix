{...}: {
  imports = [
    ./homebrew.nix
  ];

  security.pam.services.sudo_local.touchIdAuth = true;
}
