{ ... }:

{
  flake.nixosModules.duckdns = { pkgs, ... }: {
    systemd.services.duckdns-update = {
      description = "Update DuckDNS Dynamic IP";
      after = [ "network-online.target" "v2raya.service" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        EnvironmentFile = "/etc/duckdns.env";
        ExecStart = "${pkgs.writeShellScript "duckdns-update" ''
          url="https://www.duckdns.org/update?domains=''${DUCKDNS_DOMAIN}&token=''${DUCKDNS_TOKEN}&ip="

          ${pkgs.curl}/bin/curl -fsS --connect-timeout 5 --max-time 10 --proxy socks5h://127.0.0.1:20170 "$url" ||
            ${pkgs.curl}/bin/curl -fsS --connect-timeout 5 --max-time 10 "$url"
        ''}";
        TimeoutStartSec = "30s";
      };

      startAt = "*:0/5";
    };
  };
}
