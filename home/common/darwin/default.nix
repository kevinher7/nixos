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
    pyenv
    terraform-docs
    terraform-ls
    tflint
    uv
  ];
}
