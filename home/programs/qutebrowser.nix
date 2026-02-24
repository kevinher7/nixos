{ lib, ... }:
{
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
      colors.webpage.darkmode.enabled = true;
      colors.webpage.darkmode.algorithm = "lightness-cielab";
      colors.webpage.darkmode.policy.images = "never";

      tabs.indicator.width = 0;
      tabs.width = "7%";
      window.transparent = true;

      # Privacy
      content.blocking.enabled = true;
      content.canvas_reading = false;
      content.geolocation = false;
      content.webrtc_ip_handling_policy = "default-public-interface-only";
      content.cookies.accept = "all";
      content.cookies.store = true;

      content.javascript.clipboard = "access";
    };

    keyBindings = {
      normal = {
        "<Ctrl-Tab>" = "tab-focus last";
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
