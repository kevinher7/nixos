_: {
  imports = [
    ./pihole.nix
    ./nginx-proxy.nix
    ./vaultwarden.nix
    ./homepage.nix
    ./actual.nix
    ./actual-http-api.nix
    ./mail-bean.nix
    ./bean-budget.nix
    ./llm.nix
    ./ci-runner.nix
    ./harmonia.nix
    ./supervision.nix
  ];
}
