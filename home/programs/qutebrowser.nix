{
  pkgs,
  lib,
  config,
  osFamily,
  ...
}: let
  cfg = config.myPrograms.qutebrowser;
  qute-bitwarden = pkgs.runCommand "qute-bitwarden" {} ''
    substitute ${config.programs.qutebrowser.package}/share/qutebrowser/userscripts/qute-bitwarden "$out" \
      --replace-fail "totp = selection['login']['totp']" "totp = selection['login'].get('totp')"
    chmod +x "$out"
  '';
  bitwarden-wrapped = pkgs.writeShellScript "bitwarden" ''
    export PATH=${lib.makeBinPath (
      [pkgs.bitwarden-cli]
      ++ lib.optionals (osFamily == "linux") [
        pkgs.keyutils
        config.programs.rofi.finalPackage
        pkgs.xclip
        pkgs.wl-clipboard
      ]
    )}:"$PATH"
    ${lib.optionalString (osFamily == "linux") "${pkgs.keyutils}/bin/keyctl link @u @s 2>/dev/null || true"}
    exec ${qute-bitwarden} "$@"
  '';

  configDir =
    if osFamily == "darwin"
    then ".qutebrowser"
    else "${config.xdg.configHome}/qutebrowser";
in {
  config = lib.mkIf cfg.enable {
    programs.qutebrowser = {
      enable = true;
      package = pkgs.qutebrowser.override {
        enableWideVine = osFamily == "linux";
      };

      loadAutoconfig = false;

      searchEngines = {
        DEFAULT = "https://duckduckgo.com/?q={}";
        g = "https://www.google.com/search?hl=en&q={}";
        k = "https://kagi.com/search?q={}";
        n = "https://mynixos.com/search?q={}";
      };

      settings = {
        auto_save.session = true;
        downloads.location.directory =
          if osFamily == "darwin"
          then "~/Downloads"
          else "~/downloads";

        #Styles
        fonts.default_size = lib.mkForce "10pt";

        # Dark Mode
        colors = {
          webpage = {
            darkmode = {
              enabled = true;
              algorithm = "lightness-cielab";
              policy.images = "never";
            };
          };
        };

        tabs = {
          indicator.width = 0;
          width = "7%";
        };

        window.transparent = true;

        content = {
          # Privacy
          blocking.enabled = true;
          canvas_reading = false;
          geolocation = false;
          webrtc_ip_handling_policy = "default-public-interface-only";
          cookies.accept = "all";
          cookies.store = true;
          site_specific_quirks.skip = ["ua-google"];

          # Copy without Permission
          javascript.clipboard = "access";
        };
      };

      keyBindings = {
        normal = {
          "<Ctrl-Tab>" = "tab-focus last";
          "!" = "tab-focus 1";
          "\\\"" = "tab-focus 2";
          "#" = "tab-focus 3";
          "$" = "tab-focus 4";
          "%" = "tab-focus 5";
          "&" = "tab-focus 6";
          "'" = "tab-focus 7";
          "(" = "tab-focus 8";
          ")" = "tab-focus 9";

          # Userscripts
          ",p" = "spawn --userscript bitwarden --password-only";
          ",P" = "spawn --userscript bitwarden --password-only --totp";
          ",u" = "spawn --userscript bitwarden --username-only";
          ",s" = "spawn --userscript bitwarden --password-only";
          ",t" = "spawn --userscript bitwarden --totp-only";
        };
      };

      # For settings that cause dict parsing problems or require patterns (config.set)
      extraConfig = ''
        config.set("content.headers.user_agent", "Mozilla/5.0 ({os_info}; rv:135.0) Gecko/20100101 Firefox/135.0", "https://accounts.google.com/*")

        c.tabs.padding = {
          "top": 3,
          "bottom": 3,
          "left": 9,
          "right": 9
        }

        # config.set("content.webgl", False, "*")
      '';
    };

    home.file."${configDir}/userscripts/bitwarden" = {
      source = bitwarden-wrapped;
      executable = true;
    };

    home.packages = with pkgs;
      [bitwarden-cli]
      ++ lib.optionals (osFamily == "linux") [
        keyutils
        xclip
        wl-clipboard
      ];
  };
}
