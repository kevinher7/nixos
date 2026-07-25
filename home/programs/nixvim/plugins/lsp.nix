{pkgs, ...}: {
  programs.nixvim = {
    extraPackages = [pkgs.typstyle pkgs.prettierd];

    autoCmd = [
      {
        event = "VimEnter";
        desc = "Warm up prettierd daemon";
        callback.__raw = ''
          function()
            vim.fn.jobstart({"prettierd", "start"}, {detach = true})
          end
        '';
      }
    ];

    plugins = {
      conform-nvim = {
        enable = true;

        settings = {
          format_on_save = {
            lsp_format = "fallback";
            timeout_ms = 2000;
          };

          notify_on_error = true;

          formatters_by_ft = {
            python = ["ruff_format"];
            c = ["clang_format"];
            cpp = ["clang_format"];
            nix = ["alejandra"];
            typst = ["typstyle"];
            json = ["prettierd"];
            jsonc = ["prettierd"];
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
                suppress = ["formatting"];
              };
              formatting = {
                command = ["alejandra"];
              };
            };
          };

          ruff = {
            enable = true;
            filetypes = ["python"];
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
          neocmake.enable = true; # CMake
          tinymist.enable = true; # Typst
        };
      };
    };
  };
}
