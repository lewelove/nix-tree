{ ... }:

{
  flake.nixosModules.caddy = { config, ... }:
    let
      domain = config.sops.placeholder."duckdns/domain";
    in
    {
      sops.secrets."duckdns/domain" = { };

      sops.templates."Caddyfile" = {
        mode = "0644";
        reloadUnits = [ "caddy.service" ];
        content = ''
          (logging) {
            log {
              output file /var/log/caddy/access.log
              format json
            }
          }

          (auth) {
            forward_auth localhost:9091 {
              uri /api/verify?rd=https://auth.${domain}/
              copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
            }
          }

          (drop_scanners) {
            @scanners {
              path *.php *.env *.git* *.xml *.yaml *.yml *.ini *.sql *.bak *.swp *.save *.log
              path_regexp wp ^/wp-
            }
            respond @scanners "Forbidden" 403
          }

          git.${domain} {
            import logging
            import drop_scanners
            reverse_proxy localhost:3001
          }

          auth.${domain} {
            import logging
            import drop_scanners
            reverse_proxy localhost:9091
          }

          jellyfin.${domain} {
            import logging
            import drop_scanners
            reverse_proxy localhost:8096
          }

          navidrome.${domain} {
            import logging
            import drop_scanners
            reverse_proxy localhost:4533
          }

          slskd.${domain} {
            import logging
            import drop_scanners
            import auth
            reverse_proxy localhost:5030
          }

          dontstarve.${domain} {
            import logging
            import drop_scanners
            reverse_proxy localhost:3005
          }
        '';
      };

      services.caddy = {
        enable = true;
        configFile = config.sops.templates."Caddyfile".path;
      };

      systemd.services.caddy = {
        after = [ "sops-install-secrets.service" ];
        wants = [ "sops-install-secrets.service" ];
      };

      systemd.tmpfiles.rules = [
        "d /var/log/caddy 0755 caddy caddy -"
        "f /var/log/caddy/access.log 0644 caddy caddy -"
      ];

      networking.firewall.allowedTCPPorts = [ 80 443 ];
    };
}
