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
    };
  };
}
