{ pkgs, ... }:
{
  programs.nixvim = {

    extraPackages = [ pkgs.typstyle ];

    plugins = {
      conform-nvim = {
        enable = true;

        settings = {
          format_on_save = {
            lsp_fallback = "fallback";
            timeout_ms = 500;
          };

          notify_on_error = true;

          formatters_by_ft = {
            python = [ "ruff_format" ];
            c = [ "clang_format" ];
            nix = [ "nixpkgs_fmt" ];
            typst = [ "typstyle" ];
          };
        };
      };

      lsp = {
        enable = true;
        inlayHints = true;

        keymaps = {
          # silent = true;

          diagnostic = {
            "<leader>E" = "open_float";
            "<leader>[" = "goto_prev";
            "<leader>]" = "goto_next";
          };

          lspBuf = {
            "gD" = "declaration";
            "gd" = "definition";
            "gr" = "references";
            "gI" = "implementation";
            "gy" = "type_definition";
            "ga" = "code_action";

            "<leader>cr" = "rename";
          };
        };

        servers = {
          nixd = {
            enable = true;
            settings = {
              diagnostic = {
                suppress = [ "formatting" ];
              };
              formatting = {
                command = [ "nixpkgs-fmt" ];
              };
            };
          };

          ruff = {
            enable = true;
            filetypes = [ "python" ];
            extraOptions.on_attach.__raw = ''
              function(client, bufnr)
                client.server_capabilities.documentFormattingProvider = false
              end
            '';
          };

          ty = {
            enable = true;
          };

          clangd.enable = true; # C & C++
          tinymist.enable = true; # Typst
        };
      };
    };
  };
}
