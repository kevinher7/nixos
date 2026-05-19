{pkgs, ...}: {
  imports = [
    ./zsh.nix
    ./starship.nix
  ];

  home.packages = with pkgs; [
    aws-vault
    bun
    fnm
    gitleaks
    google-cloud-sdk
    jq
    just
    lefthook
    python312
    terraform-docs
    terraform-ls
    tflint
    uv
  ];
}
