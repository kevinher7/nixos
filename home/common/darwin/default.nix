{pkgs, ...}: {
  imports = [
    ./zsh.nix
    ./starship.nix
    ./stylix.nix
  ];

  home.packages = with pkgs; [
    ansible
    aws-vault
    bun
    cmake
    ninja
    fnm
    gitleaks
    google-cloud-sdk
    jq
    just
    lefthook
    pnpm
    python312
    sshpass
    terraform-docs
    terraform-ls
    tflint
    tfenv
    uv
  ];
}
