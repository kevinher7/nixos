{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.myPrograms.qutebrowser;
  pythonEnv = pkgs.python3.withPackages (ps:
    with ps; [
      tldextract
      pyperclip
    ]);

  qute-bitwarden = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/qutebrowser/qutebrowser/main/misc/userscripts/qute-bitwarden";
    sha256 = "092ayjkhzfka4d2vl05y9c5zwnf0lkn8gxairl1kgcn0wwhz0y50";
  };

  # Use the setup python env as a wrapper
  bitwarden-wrapped = pkgs.writeShellScript "bitwarden" ''
    ${pkgs.keyutils}/bin/keyctl link @u @s 2>/dev/null || true
    exec ${pythonEnv}/bin/python ${qute-bitwarden} "$@"
  '';
in {
  config = lib.mkIf cfg.enable {
    programs.qutebrowser = {
      enable = true;

      loadAutoconfig = false;

      searchEngines = {
        DEFAULT = "https://duckduckgo.com/?q={}";
        g = "https://www.google.com/search?hl=en&q={}";
        k = "https://kagi.com/search?q={}";
        n = "https://mynixos.com/search?q={}";
      };

      settings = {
        auto_save.session = true;
        downloads.location.directory = "~/downloads";

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
          ",p" = "spawn --userscript bitwarden";
          ",P" = "spawn --userscript bitwarden --totp";
        };
      };

      # For settings that cause dict parsing problems or require patterns (config.set)
      extraConfig = ''
        c.tabs.padding = {
          "top": 3,
          "bottom": 3,
          "left": 9,
          "right": 9
        }

        # config.set("content.webgl", False, "*")
      '';
    };

    # Place in userscripts in qutebrowser's userscripts directory
    xdg.configFile."qutebrowser/userscripts/bitwarden" = {
      source = bitwarden-wrapped;
      executable = true; # Critical: userscripts must be executable
    };

    home.packages = with pkgs; [
      bitwarden-cli
      keyutils
      xclip
    ];
  };
}
