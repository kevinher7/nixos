{
  config,
  lib,
  ...
}: let
  cfg = config.myHomelab.openWebui;
  vars = config.myVars;
in {
  options.myHomelab.openWebui = {
    enable = lib.mkEnableOption "Open WebUI chat front-end for the local LLM gateway";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "ai.${vars.domain}";
      description = "Public domain for Open WebUI (proxied via nginx).";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8082;
      description = "Internal port for Open WebUI. 8080/8081 are taken by Pi-hole/llama-swap.";
    };

    apiBaseUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://127.0.0.1:${toString config.myHomelab.llm.port}/v1";
      description = "OpenAI-compatible endpoint Open WebUI talks to (the llama-swap gateway).";
    };
  };

  config = lib.mkIf cfg.enable {
    # Open WebUI's license carries a branding-protection clause, so nixpkgs
    # marks it unfree. Allow just this package rather than all unfree.
    nixpkgs.config.allowUnfreePredicate = pkg: lib.elem (lib.getName pkg) ["open-webui"];

    services.open-webui = {
      enable = true;
      host = "127.0.0.1";
      inherit (cfg) port;
      # Reached only via the nginx vhost below; no direct firewall opening.
      openFirewall = false;
      environment = {
        # Telemetry off (these are the module defaults; restated because
        # setting `environment` replaces the default attrset).
        SCARF_NO_ANALYTICS = "True";
        DO_NOT_TRACK = "True";
        ANONYMIZED_TELEMETRY = "False";

        # Single backend: the llama-swap gateway. No Ollama.
        ENABLE_OLLAMA_API = "False";
        OPENAI_API_BASE_URL = cfg.apiBaseUrl;
        OPENAI_API_KEY = "none";

        # Correct external URL for links / websocket origin behind the proxy.
        WEBUI_URL = "https://${cfg.domain}";
      };
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      useACMEHost = vars.domain;
      # Allow document uploads for RAG (nginx default is 1M).
      extraConfig = "client_max_body_size 100M;";
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };
  };
}
