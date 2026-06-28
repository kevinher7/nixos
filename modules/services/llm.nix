{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myHomelab.llm;

  # GGUF weights are fetched declaratively into the Nix store and pinned by
  # hash. Swapping models = change url + hash + alias below (or override the
  # options from the host). Get a new hash with:
  #   nix store prefetch-file <url>
  modelFile = pkgs.fetchurl {
    inherit (cfg.model) url hash;
  };
in {
  options.myHomelab.llm = {
    enable = lib.mkEnableOption "llama.cpp LLM server (llama-server)";

    # Bind to all interfaces, but the firewall only trusts tailscale0 (and
    # openFirewall stays false), so the port is reachable from the tailnet
    # but never from LAN or the internet. Binding 0.0.0.0 also avoids a
    # startup race against tailscale0 getting its address.
    host = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Address llama-server binds to. Firewall restricts access to the tailnet.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8081;
      description = "Port for llama-server (HTTP web UI + OpenAI-compatible API). 8080 is taken by Pi-hole.";
    };

    threads = lib.mkOption {
      type = lib.types.int;
      default = 4;
      description = "Inference threads. The i7-7500U has 2 cores / 4 threads; try 2 if HT contention hurts.";
    };

    contextSize = lib.mkOption {
      type = lib.types.int;
      default = 4096;
      description = "Context window size in tokens.";
    };

    model = {
      alias = lib.mkOption {
        type = lib.types.str;
        default = "qwen2.5-0.5b-instruct";
        description = "Model name advertised on the OpenAI-compatible API (the \"model\" field).";
      };

      url = lib.mkOption {
        type = lib.types.str;
        default = "https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q8_0.gguf";
        description = "URL of the GGUF weights to serve.";
      };

      hash = lib.mkOption {
        type = lib.types.str;
        default = "sha256-ylnKfxPQ4VqM+ne9F+ZdJPaES1VKe2wS4Hpfif92hE4=";
        description = "SRI hash of the GGUF file. Regenerate with `nix store prefetch-file <url>`.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # The module renders `settings` into llama-server CLI flags, so each key
    # here is a long flag name (model -> --model, ctx-size -> --ctx-size, ...).
    services.llama-cpp = {
      enable = true;
      # No allowedTCPPorts needed: tailscale0 is already a trusted interface.
      openFirewall = false;
      settings = {
        inherit (cfg) host;
        inherit (cfg) port;
        model = toString modelFile;
        alias = cfg.model.alias;
        inherit (cfg) threads;
        ctx-size = cfg.contextSize;
      };
    };
  };
}
