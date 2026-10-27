{ ... }:

{
  flake.nixosModules.jellyfin-web-app = { ... }: {
    webAppsLocal.jellyfin = {
      name = "Jellyfin";
      url = "http://192.168.1.100:8096";
      icon = "jellyfin";
    };
  };
}
