{
  programs.nixvim = {

    colorschemes.catppuccin = {
      enable = true;

      settings.background = {
        dark = "frappe";
        light = "latte";
      };
    };

    clipboard = {
      providers = {
        xsel.enable = true;
      };

      # register = "unnamedplus";
    };

    opts = {
      relativenumber = true;
      number = true;

      breakindent = true;

      ignorecase = true;
      smartcase = true;

      scrolloff = 8;

      cursorline = true;
      spell = false;

      # Tab Options
      tabstop = 4;
      shiftwidth = 4;
      expandtab = true;
      autoindent = true;
    };

    autoGroups = {
      kickstart-highlight-yank = {
        clear = true;
      };
    };

    autoCmd = [
      {
        event = [ "TextYankPost" ];
        desc = "Highliht when yanking text";
        group = "kickstart-highlight-yank";
        callback = {
          __raw = ''

          function()
            vim.hl.on_yank()
          end
        '';
        };
      }
    ];

    diagnostic = {
      settings = {
        severity_sort = true;
        float = {
          boarder = "rounder";
          source = "if_many";
        };

        underline = {
          severity.__raw = ''vim.diagnostic.severity.ERROR'';
        };

        signs.__raw = ''
           vim.g.have_nerd_font and {
            text = {
              [vim.diagnostic.severity.ERROR] = '󰅚 ',
              [vim.diagnostic.severity.WARN] = '󰀪 ',
              [vim.diagnostic.severity.INFO] = '󰋽 ',
              [vim.diagnostic.severity.HINT] = '󰌶 ',
            },
          } or {}
        '';

        virtual_text = {
          source = "if_many";
          spacing = 2;
          format.__raw = ''
            function(diagnostic)
              local diagnostic_message = {
                [vim.diagnostic.severity.ERROR] = diagnostic.message,
                [vim.diagnostic.severity.WARN] = diagnostic.message,
                [vim.diagnostic.severity.INFO] = diagnostic.message,
                [vim.diagnostic.severity.HINT] = diagnostic.message,
              }
              return diagnostic_message[diagnostic.severity]
            end
          '';
        };
      };
    };
  };
}
