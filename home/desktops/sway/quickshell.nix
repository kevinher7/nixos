{config, ...}: let
  colors = config.lib.stylix.colors.withHashtag;
in {
  programs.quickshell = {
    enable = true;
    configs.sway = ./quickshell;
    activeConfig = "sway";
    systemd.enable = true;
  };

  systemd.user.services.quickshell = {
    Unit = {
      PartOf = ["sway-session.target"];
      ConditionEnvironment = "WAYLAND_DISPLAY";
      X-Restart-Triggers = ["${./quickshell}"];
    };

    Service.Environment = [
      "QS_BASE00=${colors.base00}"
      "QS_BASE03=${colors.base03}"
      "QS_BASE05=${colors.base05}"
      "QS_BASE08=${colors.base08}"
      "QS_BASE0A=${colors.base0A}"
      "QS_BASE0C=${colors.base0C}"
      "QS_BASE0D=${colors.base0D}"
      ''"QS_FONT_FAMILY=${config.stylix.fonts.sansSerif.name}"''
      "QS_FONT_SIZE=${toString config.stylix.fonts.sizes.desktop}"
    ];
  };
}
