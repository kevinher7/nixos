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
      listenPort = cfg.homepage.port;
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
                  siteMonitor = "http://127.0.0.1:${toString cfg.vaultwarden.port}";
                };
              }
            ]
            ++ lib.optionals cfg.actual.enable [
              {
                "Actual Budget" = {
                  href = "https://${cfg.actual.domain}";
                  icon = "actual-budget";
                  description = "Personal budgeting";
                  siteMonitor = "http://127.0.0.1:${toString cfg.actual.port}";
                };
              }
            ]
            ++ lib.optionals cfg.actualHttpApi.enable [
              {
                "actual-http-api" = {
                  href = "https://${cfg.actualHttpApi.domain}/api-docs/";
                  icon = "actual-budget";
                  description = "HTTP API for spend-bean";
                  siteMonitor = "http://127.0.0.1:${toString cfg.actualHttpApi.port}/api-docs/swagger.json";
                };
              }
            ]
            ++ lib.optionals cfg.mailBean.enable [
              {
                "mail-bean" = {
                  icon = "mdi-email-sync";
                  description = "Bank emails into Actual, last runs";
                  widget = {
                    type = "customapi";
                    url = "http://127.0.0.1:${toString cfg.mailBean.runLogPort}/runs.json";
                    refreshInterval = 300000;
                    display = "dynamic-list";
                    mappings = {
                      name = "created";
                      label = "at";
                      limit = 5;
                      format = "relativeDate";
                      style = "long";
                      numeric = "auto";
                    };
                  };
                };
              }
            ]
            ++ lib.optionals cfg.supervision.enable [
              {
                "Failures" = {
                  icon = "mdi-restart-alert";
                  description = "Services systemd gave up restarting";
                  widget = {
                    type = "customapi";
                    url = "http://127.0.0.1:${toString cfg.supervision.failureLogPort}/failures.json";
                    refreshInterval = 60000;
                    display = "dynamic-list";
                    mappings = {
                      name = "unit";
                      label = "at";
                      limit = 5;
                      format = "relativeDate";
                      style = "long";
                      numeric = "auto";
                    };
                  };
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
