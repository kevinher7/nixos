{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";
      have_nerd_font = true;
    };

    keymaps = [
      {
        action = "<cmd>nohlsearch<CR>";
        key = "<Esc>";
        options = {
          silent = true;
          noremap = true;
          desc = "Clean hlsearch";
        };
      }
      {
        mode = ["n" "v"];
        key = "<leader>y";
        action = "\"+y";
      }
      # Telescope
      {
        action = ":Telescope live_grep<CR>";
        key = "<leader>sg";
        options = {
          silent = true;
          noremap = true;
          desc = "[S]earch [g]rep";
        };
      }
      {
        action = ":Telescope find_files<CR>";
        key = "<leader>sf";
        options = {
          silent = true;
          noremap = true;
          desc = "[S]earch [f]iles";
        };
      }
      {
        action = ":Telescope keymaps<CR>";
        key = "<leader>sk";
        options = {
          silent = true;
          noremap = true;
          desc = "[S]earch [k]eymaps";
        };
      }
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree toggle<CR>";
        options = {
          silent = true;
          noremap = true;
          desc = "Toggle file [e]xplorer";
        };
      }
      # Git
      {
        mode = "n";
        key = "<leader>gg";
        action = "<cmd>Neogit<CR>";
        options = {
          silent = true;
          noremap = true;
          desc = "[G]it status panel";
        };
      }
      {
        mode = "n";
        key = "<leader>gd";
        action = "<cmd>DiffviewOpen<CR>";
        options = {
          silent = true;
          noremap = true;
          desc = "[G]it [d]iff view";
        };
      }
      {
        mode = "n";
        key = "<leader>gc";
        action = "<cmd>DiffviewClose<CR>";
        options = {
          silent = true;
          noremap = true;
          desc = "[G]it diff [c]lose";
        };
      }
      {
        mode = "n";
        key = "<leader>gh";
        action = "<cmd>DiffviewFileHistory %<CR>";
        options = {
          silent = true;
          noremap = true;
          desc = "[G]it file [h]istory";
        };
      }
      {
        mode = "n";
        key = "]h";
        action = "<cmd>Gitsigns next_hunk<CR>";
        options = {desc = "Next Git [h]unk";};
      }
      {
        mode = "n";
        key = "[h";
        action = "<cmd>Gitsigns prev_hunk<CR>";
        options = {desc = "Previous Git [h]unk";};
      }
      {
        mode = "n";
        key = "<leader>ul";
        action = "<cmd>lua require('lint').try_lint()<CR>";
        options = {
          silent = true;
          noremap = true;
          desc = "[L]int buffer";
        };
      }
      {
        mode = "n";
        key = "<leader>x";
        action = "<cmd>lua vim.diagnostic.setloclist()<CR>";
        options = {
          silent = true;
          noremap = true;
          desc = "Populate loclist with diagnostics";
        };
      }
    ];
  };
}
