{
  config,
  username,
  ...
}: let
  apiKey = {
    sopsFile = ../../secrets/api-keys.yaml;
    owner = username;
    mode = "0400";
  };
in {
  sops = {
    secrets = {
      anthropic_api_key = apiKey;
      openai_api_key = apiKey;
      openrouter_api_key = apiKey;
    };

    templates."opencode.env" = {
      owner = username;
      mode = "0400";
      content = ''
        ANTHROPIC_API_KEY=${config.sops.placeholder.anthropic_api_key}
        OPENAI_API_KEY=${config.sops.placeholder.openai_api_key}
        OPENROUTER_API_KEY=${config.sops.placeholder.openrouter_api_key}
      '';
    };
  };
}
