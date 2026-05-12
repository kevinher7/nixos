{
  config,
  lib,
  ...
}: let
  cfg = config.myHomelab;
  inherit (config.myVars) domain;
in {
  options.myHomelab.homepage = {
    enable = lib.mkEnableOption "Homepage service dashboard";
  };

  config = lib.mkIf cfg.homepage.enable {
    services.homepage-dashboard = {
      enable = true;
      openFirewall = false;
      allowedHosts = "${domain},localhost:8082,127.0.0.1:8082";

      settings = {
        title = "Kevin's Home Lab";
        theme = "dark";
        color = "slate";
        background = "solid";
        layout = {
          Services = {
            style = "row";
            columns = 4;
          };
        };
      };

      widgets = [
        {
          greeting = {
            text = "Kevin's Home Lab";
            text_size = "4xl";
          };
        }
      ];

      services = [
        {
          "Services" = [
            {
              "Pi-hole" = {
                href = "https://pihole.${domain}";
                icon = "pi-hole";
                description = "DNS sinkhole & ad blocker";
                siteMonitor = "http://localhost:8080";
              };
            }
            {
              "Vaultwarden" = {
                href = "https://vault.${domain}";
                icon = "bitwarden";
                description = "Password manager";
                siteMonitor = "http://localhost:1821";
              };
            }
            {
              "OpenCode" = {
                href = "https://code.${domain}";
                icon = "opencode";
                description = "Web-based AI assistant";
                siteMonitor = "http://localhost:4096";
              };
            }
            {
              "Tailscale" = {
                href = "https://login.tailscale.com/admin/machines";
                icon = "tailscale";
                description = "Mesh VPN";
              };
            }
          ];
        }
      ];

      bookmarks = [
        {
          "Network" = [
            {
              "Router" = [
                {
                  abbr = "RT";
                  href = "http://192.168.0.1";
                  icon = "router";
                }
              ];
            }
          ];
        }
      ];
    };

    services.nginx.virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8082";
        proxyWebsockets = true;
      };
    };
  };
}
