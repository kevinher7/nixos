{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./zsh.nix
    ./starship.nix
    ./stylix.nix
    ./rtk.nix
  ];

  home.packages = with pkgs; [
    aws-vault
    bun
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
    fnm
    gitleaks
    google-cloud-sdk
    jq
    just
    lefthook
    pnpm
    (poetry.override {python3 = python312;})
    python312
    terraform-docs
    terraform-ls
    tflint
    uv
  ];
}
