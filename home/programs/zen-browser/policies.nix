{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.myPrograms.zen-browser.enable {
    programs.zen-browser.policies = {
      # Nix manages updates via flake.lock; disable in-app updates.
      DisableAppUpdate = true;
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DontCheckDefaultBrowser = true;
    };
  };
}
