{
  programs.nixvim = {
    plugins.nvim-autopairs = {
      enable = true;

      settings = {
        check_ts = true;
      };

      luaConfig.post = ''
        local npairs = require("nvim-autopairs")
        local Rule = require("nvim-autopairs.rule")
        -- local cond = require("nvim-autopairs.conds")

        npairs.add_rule(
          Rule("$", "$", "typst")
            -- This prevents the pair from triggering if the next character 
            -- is already a "$" (common for closing manually)
            -- :with_pair(cond.not_after_regex("$"))

            -- Optional: If you want $$ to behave like display math 
            -- and move to a new line on Enter
            -- :with_cr(cond.none()) 
        )
      '';
    };
  };
}
