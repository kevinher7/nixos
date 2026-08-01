{pkgs, ...}: let
  claude-assistant-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "claude-assistant.nvim";
    version = "unstable-2026-07-14";

    src = pkgs.fetchFromGitHub {
      owner = "NaabZer";
      repo = "claude-assistant.nvim";
      rev = "982271f304701a608016b5e022868feb2fc50e12";
      hash = "sha256-zWWZvPcC9Cn9ZqYuDd6LANGdBZraS02DSrHn9LhHwdM=";
    };
  };
in {
  programs.nixvim = {
    plugins.claudecode = {
      enable = true;
      # claude-assistant owns claudecode.setup() below so it can inject its
      # assistant role prompt into the Claude terminal command.
      callSetup = false;
    };

    # Keep PATH claude (managed by llm-agents flake) as the dependency
    dependencies.claude-code.enable = false;

    extraPlugins = [claude-assistant-nvim];

    keymaps = [
      {
        mode = ["n" "x" "t"];
        key = "<C-,>";
        action = "<C-\\><C-n><cmd>ClaudeCodeFocus<CR>";
        options = {
          silent = true;
          noremap = true;
          desc = "Focus/hide Claude";
        };
      }
      {
        mode = ["n" "t"];
        key = "<C-.>";
        action = "<C-\\><C-n><C-w>p";
        options = {
          silent = true;
          noremap = true;
          desc = "Unfocus Claude (keep visible)";
        };
      }
    ];

    extraConfigLua = ''
      require("claude-assistant").setup({
        manage_claudecode = true,
        claudecode = {
          terminal = {
            provider = "native",
          },
        },
        keymaps = {
          enable = true,
          review = "<leader>ar",
          explain = "<leader>ae",
          paste = "<leader>ap",
          explain_file = "<leader>aE",
          quicksend = "<leader>as",
          review_diff = "<leader>aR",
          quicksend_insert = "<C-s>",
        },
      })
    '';
  };
}
