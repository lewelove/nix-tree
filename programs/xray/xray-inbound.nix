{ ... }:

{
  flake.nixosModules.xray-inbound = { config, pkgs, ... }:
    let
      xrayConfig = {
        log = {
          loglevel = "warning";
        };
        dns = {
          tag = "dns-module";
          servers = [ "127.0.0.1" ];
        };
        inbounds = [
          {
            tag = "vless-in";
            listen = "0.0.0.0";
            port = 4443;
            protocol = "vless";
            settings = {
              clients = [
                {
                  id = config.sops.placeholder."xray/uuid";
                  flow = "xtls-rprx-vision";
                }
              ];
              decryption = "none";
            };
            streamSettings = {
              network = "tcp";
              security = "reality";
              realitySettings = {
                show = false;
                dest = "smartcaptcha.yandexcloud.net:443";
                xver = 0;
                serverNames = [
                  "smartcaptcha.yandexcloud.net"
                  "rutube.ru"
                  "yandex.ru"
                ];
                privateKey = config.sops.placeholder."xray/private_key";
                shortIds = [
                  config.sops.placeholder."xray/short_id"
                ];
              };
            };
            sniffing = {
              enabled = true;
              destOverride = [ "http" "tls" "quic" ];
              routeOnly = true;
            };
          }
        ];
        outbounds = [
          {
            tag = "dns-out";
            protocol = "dns";
            settings = {
              network = "udp";
              address = "127.0.0.1";
              port = 53;
            };
          }
          {
            tag = "direct";
            protocol = "freedom";
          }
          {
            tag = "block";
            protocol = "blackhole";
          }
          {
            tag = "v2raya-proxy";
            protocol = "socks";
            settings = {
              servers = [
                {
                  address = "127.0.0.1";
                  port = 20170;
                }
              ];
            };
          }
        ];
        routing = {
          domainStrategy = "IPOnDemand";
          rules = [
            {
              type = "field";
              inboundTag = [ "dns-module" ];
              outboundTag = "direct";
            }
            {
              type = "field";
              port = "53";
              outboundTag = "dns-out";
            }
            {
              type = "field";
              ip = [
                "0.0.0.0/8"
                "127.0.0.0/8"
                "::/128"
              ];
              outboundTag = "block";
            }
            {
              type = "field";
              ip = [
                "192.168.0.0/16"
                "10.0.0.0/8"
                "172.16.0.0/12"
              ];
              outboundTag = "direct";
            }
            {
              type = "field";
              network = "tcp,udp";
              outboundTag = "v2raya-proxy";
            }
          ];
        };
      };
    in
    {
      networking.firewall.allowedTCPPorts = [ 4443 ];
      networking.firewall.allowedUDPPorts = [ 4443 ];

      sops.secrets."xray/uuid" = { };
      sops.secrets."xray/private_key" = { };
      sops.secrets."xray/short_id" = { };

      sops.templates."xray-inbound.json" = {
        owner = "root";
        mode = "0444";
        content = builtins.toJSON xrayConfig;
      };

      systemd.services.xray-inbound = {
        description = "Xray Inbound VLESS-Reality Server";
        after = [ "network.target" "v2raya.service" ];
        wantedBy = [ "multi-user.target" ];

        environment = {
          XRAY_LOCATION_ASSET = "${pkgs.v2ray-rules-dat}/share/v2ray";
        };

        serviceConfig = {
          ExecStart = "${pkgs.xray}/bin/xray run -config ${config.sops.templates."xray-inbound.json".path}";
          Restart = "always";
          RestartSec = "3s";
          User = "root";
        };
      };
    };
}
