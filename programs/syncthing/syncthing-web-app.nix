{ ... }:

{
  flake.nixosModules.syncthing-web-app = { ... }:
    let
      homeName = "Syncthing (Home)";
      homeDomain = "syncthing.localhost";
      homePort = 8384;

      labName = "Syncthing (Lab)";
      labDomain = "syncthing-lab.localhost";
      labIp = "192.168.1.100";
      labPort = 8384;
    in
    {
      networking.hosts."127.0.0.1" = [ homeDomain labDomain ];

      services.nginx.enable = true;

      services.nginx.virtualHosts = {
        "${homeDomain}" = {
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString homePort}";
            proxyWebsockets = true;
          };
        };

        "${labDomain}" = {
          locations."/" = {
            proxyPass = "http://${labIp}:${toString labPort}";
            proxyWebsockets = true;
          };
        };
      };

      webApps.syncthing-home = {
        name = homeName;
        url = "http://${homeDomain}";
        icon = "syncthing";
      };

      webApps.syncthing-lab = {
        name = labName;
        url = "http://${labDomain}";
        icon = "syncthing";
      };

    };
}
