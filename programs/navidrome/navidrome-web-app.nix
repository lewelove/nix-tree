{ ... }:

{
  flake.nixosModules.navidrome-web-app = { ... }: {
    webApps.navidrome = {
      name = "Navidrome";
      url = "https://navidrome.lewelaboratory.duckdns.org";
      browser = "chromium-lan";
    };
  };
}
