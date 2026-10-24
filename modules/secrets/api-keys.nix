{
  config,
  hostname,
  lib,
  username,
  ...
}: let
  cfg = config.myModules.secrets;
in {
  options.myModules.secrets.openrouterApiKey.enable =
    lib.mkEnableOption "the OpenRouter API key secret";

  config = lib.mkIf cfg.openrouterApiKey.enable {
    sops.secrets.openrouter_api_key = {
      sopsFile = ../../secrets/api-keys/${hostname}.yaml;
      owner = username;
      mode = "0400";
    };
  };
}
