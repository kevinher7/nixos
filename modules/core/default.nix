_: {
  imports = [
    ./users.nix
    ./packages.nix
    ./pki.nix
  ];

  environment.enableAllTerminfo = true;
}
