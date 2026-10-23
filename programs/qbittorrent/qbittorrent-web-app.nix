{ ... }:

{
  flake.nixosModules.qbittorrent-web-app = { ... }:
    let
      domain = "qbittorrent.lab";
      ip = "192.168.1.100";
      port = 8081;
    in
    {
      networking.hosts."${ip}" = [ domain ];

      webApps.qbittorrent = {
        name = "qBittorrent";
        url = "http://${domain}:${toString port}";
        icon = "qbittorrent";
      };
    };
}
