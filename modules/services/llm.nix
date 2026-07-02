{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myHomelab.llm;

  llamaServer = lib.getExe' pkgs.llama-cpp "llama-server";

  # Build the llama-server launch command for one model. llama-swap assigns a
  # free port per backend and substitutes the literal token ${PORT} at launch,
  # so it must survive Nix as the literal text "${PORT}" (hence \${PORT}).
  mkCmd = m: let
    modelFile = pkgs.fetchurl {inherit (m) url hash;};
  in
    lib.concatStringsSep " " [
      llamaServer
      "--model ${modelFile}"
      "--host 127.0.0.1"
      "--port \${PORT}"
      "--ctx-size ${toString m.ctxSize}"
      "--threads ${toString m.threads}"
    ];

  mkModel = _: m:
    {
      cmd = mkCmd m;
      inherit (m) ttl;
    }
    // lib.optionalAttrs (m.aliases != []) {inherit (m) aliases;};
in {
  options.myHomelab.llm = {
    enable = lib.mkEnableOption "llama-swap LLM gateway (llama.cpp backends)";

    # Bind to all interfaces, but the firewall only trusts tailscale0 (and
    # openFirewall stays false), so the gateway is reachable from the tailnet
    # but never from LAN or the internet. Binding 0.0.0.0 also avoids a
    # startup race against tailscale0 getting its address.
    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Address llama-swap binds to. Firewall restricts access to the tailnet.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8081;
      description = "Port for the llama-swap gateway (OpenAI-compatible API + UI). 8080 is taken by Pi-hole.";
    };

    models = lib.mkOption {
      description = ''
        GGUF models llama-swap can serve. The attribute name is the model id
        clients request on the OpenAI API. llama-swap runs one model at a time
        and swaps on demand, which suits this low-RAM CPU box. Add a model by
        adding an entry (get the hash with `nix store prefetch-file <url>`).
      '';
      default = {
        "qwen2.5-0.5b-instruct" = {
          url = "https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q8_0.gguf";
          hash = "sha256-ylnKfxPQ4VqM+ne9F+ZdJPaES1VKe2wS4Hpfif92hE4=";
        };
        "qwen2.5-1.5b-instruct" = {
          url = "https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf";
          hash = "sha256-ahouttFWIr88loVyBjUbqX4a8Www16dO44lw5DTpQH4=";
        };
      };
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          url = lib.mkOption {
            type = lib.types.str;
            description = "URL of the GGUF weights.";
          };

          hash = lib.mkOption {
            type = lib.types.str;
            description = "SRI hash of the GGUF file. Regenerate with `nix store prefetch-file <url>`.";
          };

          ctxSize = lib.mkOption {
            type = lib.types.int;
            default = 4096;
            description = "Context window size in tokens.";
          };

          threads = lib.mkOption {
            type = lib.types.int;
            default = 4;
            description = "Inference threads. The i7-7500U has 2 cores / 4 threads.";
          };

          aliases = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "Extra model names that also route to this model.";
          };

          ttl = lib.mkOption {
            type = lib.types.int;
            default = 300;
            description = "Idle seconds before llama-swap unloads the model to free RAM.";
          };
        };
      });
    };
  };

  config = lib.mkIf cfg.enable {
    services.llama-swap = {
      enable = true;
      inherit (cfg) listenAddress port;
      # No allowedTCPPorts needed: tailscale0 is already a trusted interface.
      openFirewall = false;
      settings = {
        # Model load + first health check can be slow on CPU; be generous.
        healthCheckTimeout = 120;
        models = lib.mapAttrs mkModel cfg.models;
      };
    };
  };
}
