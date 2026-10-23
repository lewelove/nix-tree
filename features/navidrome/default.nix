{ ... }:

{
  flake.nixosModules.navidrome = { ... }: {
    webApps.navidrome = {
      name = "Navidrome";
      url = "https://navidrome.lewelaboratory.duckdns.org";
    };
  };
}
