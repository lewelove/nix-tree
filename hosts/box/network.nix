{ ... }:

{
  networking.firewall.trustedInterfaces = [ "tun0" ];

  services.sing-box = {
    enable = true;
    settings = {
      log.level = "warn";

      dns = {
        servers = [
          {
            type = "tcp";
            tag = "quad9";
            server = "9.9.9.9";
            server_port = 53;
            detour = "v2raya-proxy";
          }
        ];
        final = "quad9";
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
          tag = "v2raya-proxy";
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
        default_domain_resolver = "quad9";
        final = "v2raya-proxy";
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
              "10.0.0.0/8"
              "127.0.0.0/8"
              "172.16.0.0/12"
              "192.168.0.0/16"
            ];
            action = "route";
            outbound = "direct";
          }
        ];
      };
    };
  };
}
