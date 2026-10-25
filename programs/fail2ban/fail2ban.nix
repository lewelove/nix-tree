{ ... }:

{
  flake.nixosModules.fail2ban = { ... }: {
    services.fail2ban = {
      enable = true;
      bantime = "24h";
      maxretry = 5;

      ignoreIP = [
        "127.0.0.1/8"
        "192.168.1.0/24"
      ];

      jails = {
        sshd.settings = {
          enabled = true;
          port = "ssh";
          filter = "sshd";
          maxretry = 3;
          findtime = "24h";
        };

        caddy-scanners = {
          settings = {
            enabled = true;
            filter = "caddy-scanners";
            logpath = "/var/log/caddy/access.log";
            port = "http,https";
            backend = "auto";
            maxretry = 3;
            findtime = "10m";
            bantime = "24h";
          };
        };
      };
    };

    environment.etc."fail2ban/filter.d/caddy-scanners.conf".text = ''
      [Definition]
      failregex = ^.*"remote_ip":"<HOST>(:\d+)?".*"status":(403|444).*$
      ignoreregex =
    '';
  };
}
