{pkgs, ...}: {
  imports = [
    ./zsh.nix
    ./starship.nix
    ./stylix.nix
  ];

  home.packages = with pkgs; [
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
    terraform-docs
    terraform-ls
    tflint
    uv
  ];
}
