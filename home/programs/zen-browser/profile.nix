# Extracted from ~/Library/Application Support/zen/Profiles/7otzd7ja.Default (release)/
# User extensions (1Password, Multi-Account Containers), spaces, containers,
# pins, bookmarks and search engines are preserved on disk; declare here as needed.
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.myPrograms.zen-browser.enable {
    programs.zen-browser.profiles.default = {
      isDefault = true;

      settings = {
        # Locale / region (Japan)
        "browser.search.region" = "JP";
        "doh-rollout.home-region" = "JP";
        "browser.translations.neverTranslateLanguages" = "ja,es";

        # 1Password handles password storage; turn off built-in.
        "signon.autofillForms" = false;
        "signon.rememberSignons" = false;
        "dom.forms.autocomplete.formautofill" = true;

        # UI behaviour
        "sidebar.visibility" = "hide-sidebar";
        "findbar.highlightAll" = true;
        "browser.contentblocking.category" = "standard";
        "extensions.pictureinpicture.enable_picture_in_picture_overrides" = true;

        # Zen-specific
        "zen.view.compact.enable-at-startup" = false;
        "zen.view.compact.should-enable-at-startup" = true;
        "zen.welcome-screen.seen" = true;
        "zen.live-folders.promotion.shown" = true;
        "zen.site-data-panel.show-callout" = false;
        "zen.swipe.is-fast-swipe" = false;
      };

      # search.force = true is intentionally NOT set: the live profile keeps
      # Google as appDefaultEngineId alongside built-in DDG/Bing/Wikipedia/
      # Perplexity/Startpage. Forcing would wipe those on activation. Flip to
      # true once every engine is enumerated below.
      search = {
        default = "google";
        engines = {
          "T3 Chat" = {
            # User-added engine recreated from search.json.mozlz4. The live
            # profile's iconMapObj is an inline data: URI, so no icon here —
            # Zen falls back to a generic globe.
            definedAliases = ["@t3"];
            # urls = [{template = "https://t3.chat/?q={searchTerms}";}];
          };
        };
      };

      # Preserved on disk; declare later as needed.
      #
      # extensions.packages — prefer rycee NUR firefox-addons input. Existing
      #   xpis under extensions/ stay in place for now:
      #     {d634138d-c276-4fc8-924b-40a0ea21d284}  1Password (AMO: 1password-x-password-manager)
      #     @testpilot-containers                   Multi-Account Containers (AMO: multi-account-containers)
      #
      # containers — Personal / Work / banking / shopping. Declaring requires
      #   closing Zen before each home-manager switch.
      #
      # spaces — "Me" (🫩, container 1) and "work" (🐝, container 2), both with
      #   gradient themes. Declaring requires closing Zen.
      #
      # pins — ~75 pinned tabs across the two spaces. Declaring requires
      #   closing Zen.
      #
      # bookmarks — ~8 in places.sqlite. force = true would overwrite the
      #   live DB; declare when curated.
      #
      # userChrome / userContent — none in profile (only auto-generated
      #   zen-themes.css from Zen Mods). Nothing to migrate.
      #
      # keyboardShortcuts — custom set (version=18). Declaring requires
      #   closing Zen on each switch.
    };
  };
}
