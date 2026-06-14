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

    port = lib.mkOption {
      type = lib.types.port;
      default = 8082;
      description = "Internal port for the Homepage dashboard (proxied by nginx)";
    };
  };

  config = lib.mkIf cfg.homepage.enable {
    services.homepage-dashboard = {
      enable = true;
      openFirewall = false;
      allowedHosts = let
        port = toString cfg.homepage.port;
      in "${domain},localhost:${port},127.0.0.1:${port}";

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
          "Services" =
            [
              {
                "Pi-hole" = {
                  href = "https://pihole.${domain}";
                  icon = "pi-hole";
                  description = "DNS sinkhole & ad blocker";
                  siteMonitor = "http://localhost:${cfg.pihole.webPort}";
                };
              }
              {
                "Vaultwarden" = {
                  href = "https://vault.${domain}";
                  icon = "bitwarden";
                  description = "Password manager";
                  siteMonitor = "http://localhost:${toString cfg.vaultwarden.port}";
                };
              }
              {
                "OpenCode" = {
                  href = "https://code.${domain}";
                  icon = "opencode";
                  description = "Web-based AI assistant";
                  siteMonitor = "http://localhost:${toString config.myVars.opencodePort}";
                };
              }
            ]
            ++ lib.optionals cfg.t3code.enable [
              {
                "T3 Code" = {
                  href = "https://${cfg.t3code.domain}";
                  icon = "https://${cfg.t3code.domain}/favicon.ico";
                  description = "Headless coding agent UI";
                  siteMonitor = "http://${cfg.t3code.host}:${toString cfg.t3code.port}";
                };
              }
            ]
            ++ lib.optionals cfg.actual.enable [
              {
                "Actual Budget" = {
                  href = "https://${cfg.actual.domain}";
                  icon = "actual-budget";
                  description = "Personal budgeting";
                  siteMonitor = "http://localhost:${toString cfg.actual.port}";
                };
              }
            ]
            ++ [
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
                  href = "http://${config.myVars.lan.gateway}";
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
        proxyPass = "http://127.0.0.1:${toString cfg.homepage.port}";
        proxyWebsockets = true;
      };
    };
  };
}
