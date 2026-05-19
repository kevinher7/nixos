{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.myPrograms.zen-browser.enable {
    programs.zen-browser.profiles.default.search = {
      force = true;
      default = "google";
      engines = {
        google = {
          name = "Google";
          urls = [{template = "https://www.google.com/search?q={searchTerms}";}];
          definedAliases = ["@g"];
        };
        bing = {
          name = "Bing";
          urls = [{template = "https://www.bing.com/search?q={searchTerms}";}];
          definedAliases = ["@b"];
        };
        ddg = {
          name = "DuckDuckGo";
          urls = [{template = "https://duckduckgo.com/?q={searchTerms}";}];
          definedAliases = ["@ddg"];
        };
        perplexity = {
          name = "Perplexity";
          urls = [{template = "https://www.perplexity.ai/search?q={searchTerms}";}];
          definedAliases = ["@p"];
        };
        wikipedia = {
          name = "Wikipedia (en)";
          urls = [{template = "https://en.wikipedia.org/wiki/Special:Search?search={searchTerms}";}];
          definedAliases = ["@w"];
        };
        t3chat = {
          name = "T3 Chat";
          urls = [{template = "https://t3.chat/new?q={searchTerms}";}];
          definedAliases = ["@t3"];
        };
        startpage = {
          name = "Startpage";
          urls = [{template = "https://www.startpage.com/do/dsearch?query={searchTerms}";}];
          definedAliases = ["@sp"];
        };
      };
    };
  };
}
