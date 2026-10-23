{ ... }:

{
  flake.nixosModules.jellyfin-web-app = { ... }: {
    webApps.jellyfin = {
      name = "Jellyfin";
      url = "https://jellyfin.lewelaboratory.duckdns.org/";
      icon = "jellyfin";
    };
  };
}
