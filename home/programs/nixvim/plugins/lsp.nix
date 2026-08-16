{
  lib,
  osFamily,
  pkgs,
  ...
}: {
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

    lsp = {
      inlayHints.enable = true;

      keymaps = [
        {
          key = "<leader>E";
          mode = "n";
          action.__raw = "function() vim.diagnostic.open_float() end";
        }
        {
          key = "<leader>[";
          mode = "n";
          action.__raw = "function() vim.diagnostic.jump({count = -1, float = true}) end";
        }
        {
          key = "<leader>]";
          mode = "n";
          action.__raw = "function() vim.diagnostic.jump({count = 1, float = true}) end";
        }

        # vim.lsp.buf.*
        {
          key = "gD";
          mode = "n";
          lspBufAction = "declaration";
        }
        {
          key = "gd";
          mode = "n";
          lspBufAction = "definition";
        }
        {
          key = "gr";
          mode = "n";
          lspBufAction = "references";
        }
        {
          key = "gI";
          mode = "n";
          lspBufAction = "implementation";
        }
        {
          key = "gy";
          mode = "n";
          lspBufAction = "type_definition";
        }
        {
          key = "ga";
          mode = "n";
          lspBufAction = "code_action";
        }
        {
          key = "<leader>cr";
          mode = "n";
          lspBufAction = "rename";
        }
      ];

      servers = {
        nixd = {
          enable = true;
          config.settings.nixd = {
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
          config = {
            filetypes = ["python"];
            on_attach.__raw = ''
              function(client, bufnr)
                client.server_capabilities.documentFormattingProvider = false
              end
            '';
          };
        };

        ty = {
          enable = true;
        };

        clangd = {
          enable = true; # C & C++
          config.cmd = [
            (lib.getExe' pkgs.clang-tools (
              if osFamily == "darwin"
              then "clangd-unwrapped"
              else "clangd"
            ))
            "--background-index"
            "--clang-tidy"
          ];
        };

        ts_ls.enable = true; # TypeScript & JavaScript

        neocmake.enable = true; # CMake
        tinymist.enable = true; # Typst
      };
    };

    plugins = {
      lspconfig.enable = true;

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
            javascript = ["prettierd"];
            javascriptreact = ["prettierd"];
            typescript = ["prettierd"];
            typescriptreact = ["prettierd"];
          };
        };
      };
    };
  };
}
