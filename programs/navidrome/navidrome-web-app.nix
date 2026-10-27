{ ... }:

{
  flake.nixosModules.navidrome-web-app = { ... }: {
    webAppsLocal.navidrome = {
      name = "Navidrome";
      url = "https://navidrome.lewelaboratory.duckdns.org";
    };
  };
}
