{
  config,
  lib,
  ...
}: let
  colors = config.lib.stylix.colors.withHashtag;
in {
  programs.quickshell = {
    enable = true;
    configs.sway = ./quickshell;
    activeConfig = "sway";
    systemd.enable = true;
  };

  programs.nixvim.lsp.servers.qmlls.config.cmd_env = lib.mkIf config.myPrograms.nixvim.enable {
    QML_IMPORT_PATH = "${config.programs.quickshell.package}/lib/qt-6/qml";
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
      "QS_BASE0C=${colors.base0C}"
      "QS_BASE0D=${colors.base0D}"
      ''"QS_FONT_FAMILY=${config.stylix.fonts.sansSerif.name}"''
      ''"QS_ICON_FONT_FAMILY=${config.stylix.fonts.monospace.name}"''
      "QS_FONT_SIZE=14" # Not using stylix. Configures the relative size of the Bar
    ];
  };
}
