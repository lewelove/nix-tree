{ ... }:

{
  flake.nixosModules.sing-box = { pkgs, ... }: {
    services.sing-box = {
      enable = true;
      # enable = false;
      settings = {
        log.level = "info";

        dns = {
          servers = [
            {
              type = "tcp";
              tag = "cf";
              server = "1.1.1.1";
              server_port = 53;
              detour = "lab-proxy";
            }
          ];
          final = "cf";
          strategy = "prefer_ipv4";
        };

        inbounds = [
          {
            type = "tun";
            tag = "tun-in";
            interface_name = "tun0";
            address = [ "172.19.0.1/30" ];
            auto_route = true;
            strict_route = true;
            stack = "mixed";
          }
        ];

        outbounds = [
          {
            type = "socks";
            tag = "lab-proxy";
            server = "192.168.1.100";
            server_port = 20170;
          }
          {
            type = "direct";
            tag = "direct";
          }
        ];

        route = {
          auto_detect_interface = true;
          default_domain_resolver = "cf";
          final = "lab-proxy";
          rules = [
            {
              action = "sniff";
            }
            {
              protocol = "dns";
              action = "hijack-dns";
            }
            {
              port = [ 53 ];
              action = "hijack-dns";
            }
            {
              ip_cidr = [
                "192.168.1.0/24"
                "127.0.0.0/8"
                "10.0.0.0/8"
              ];
              action = "route";
              outbound = "direct";
            }
          ];
        };
      };
    };
  };
}

