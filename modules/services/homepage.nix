{
  config,
  lib,
  ...
}: let
  cfg = config.myHomelab;
in {
  options.myHomelab.homepage = {
    enable = lib.mkEnableOption "Homepage service dashboard";
  };

  config = lib.mkIf cfg.homepage.enable {
    services.homepage-dashboard = {
      enable = true;
      openFirewall = false;
      allowedHosts = "uribogoat.duckdns.org,localhost:8082,127.0.0.1:8082";

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
                href = "https://pihole.uribogoat.duckdns.org";
                icon = "pi-hole";
                description = "DNS sinkhole & ad blocker";
                siteMonitor = "http://localhost:8080";
              };
            }
            {
              "Vaultwarden" = {
                href = "https://vault.uribogoat.duckdns.org";
                icon = "bitwarden";
                description = "Password manager";
                siteMonitor = "http://localhost:1821";
              };
            }
            {
              "OpenCode" = {
                href = "https://code.uribogoat.duckdns.org";
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

    services.nginx.virtualHosts."uribogoat.duckdns.org" = {
      forceSSL = true;
      useACMEHost = "uribogoat.duckdns.org";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8082";
        proxyWebsockets = true;
      };
    };
  };
}
