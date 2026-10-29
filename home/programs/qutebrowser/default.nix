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
    export PATH=${lib.makeBinPath [
      pkgs.bitwarden-cli
      pkgs.keyutils
      config.programs.rofi.finalPackage
      pkgs.xclip
      pkgs.wl-clipboard
    ]}:"$PATH"
    ${pkgs.keyutils}/bin/keyctl link @u @s 2>/dev/null || true
    exec ${qute-bitwarden} "$@"
  '';

  qutebrowser-darwin = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "qutebrowser";
    version = "3.7.0";
    src = pkgs.fetchurl {
      url = "https://github.com/qutebrowser/qutebrowser/releases/download/v${finalAttrs.version}/qutebrowser-${finalAttrs.version}-arm64.dmg";
      hash = "sha256-mBcCQb8Sov4d6r/8gSC3DcjgDlVbtxLDh1HESPBJVKM=";
    };
    nativeBuildInputs = [pkgs.undmg];
    sourceRoot = ".";
    installPhase = ''
      mkdir -p "$out/Applications" "$out/bin"
      cp -R qutebrowser.app "$out/Applications/"
      ln -s "$out/Applications/qutebrowser.app/Contents/MacOS/qutebrowser" "$out/bin/qutebrowser"
    '';
    meta.platforms = ["aarch64-darwin"];
  });
in {
  imports = [./theme.nix ./mpv.nix];

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      programs.qutebrowser = {
        enable = true;
        package =
          if osFamily == "darwin"
          then qutebrowser-darwin
          else pkgs.qutebrowser.override {enableWideVine = true;};

        loadAutoconfig = false;

        perDomainSettings =
          {
            "https://www.youtube.com/*".content = {
              autoplay = false;
              blocking.enabled = false;
            };
          }
          // lib.optionalAttrs (osFamily == "linux") {
            "https://accounts.google.com/*".content.headers.user_agent = "Mozilla/5.0 ({os_info}; rv:135.0) Gecko/20100101 Firefox/135";
          };

        quickmarks = {
          da = "https://animestore.docomo.ne.jp/";
          yt = "https://youtube.com/";
          cg = "https://chatgpt.com/";
          gh = "https://github.com/kevinher7";
          bh = "https://beanhaven.net";
          vb = "https://vault.beanhaven.net";
          bb = "https://budget.beanhaven.net";
        };

        searchEngines = {
          DEFAULT = "https://duckduckgo.com/?q={}";
          g = "https://www.google.com/search?hl=en&q={}";
          k = "https://kagi.com/search?q={}";
          n = "https://mynixos.com/search?q={}";
        };

        settings = {
          auto_save.session = true;
          session.lazy_restore = true;
          downloads.location.directory =
            if osFamily == "darwin"
            then "~/Downloads"
            else "~/downloads";

          #Styles
          fonts.default_size = lib.mkForce "10pt";
          fonts.tabs.selected = lib.mkForce "12pt default_family";
          fonts.tabs.unselected = lib.mkForce "12pt default_family";

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
            position = "left";
            indicator.width = 0;
            width = "15%";
          };

          statusbar.show = "in-mode";

          window = {
            hide_decoration = true;
            transparent = true;
          };

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
            ",r" = "config-source";
            ",w" = "config-cycle --temp tabs.show always never";
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
    }

    (lib.mkIf (osFamily == "linux") {
      programs.qutebrowser.settings.content.site_specific_quirks.skip = ["ua-google"];

      programs.qutebrowser.keyBindings.normal = {
        ",p" = "spawn --userscript bitwarden --password-only";
        ",P" = "spawn --userscript bitwarden --password-only --totp";
        ",u" = "spawn --userscript bitwarden --username-only";
        ",s" = "spawn --userscript bitwarden";
        ",t" = "spawn --userscript bitwarden --totp-only";
      };

      xdg.configFile."qutebrowser/userscripts/bitwarden" = {
        source = bitwarden-wrapped;
        executable = true;
      };

      home.packages = with pkgs; [
        bitwarden-cli
        keyutils
        xclip
        wl-clipboard
      ];
    })
  ]);
}
