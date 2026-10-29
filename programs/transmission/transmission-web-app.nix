{ ... }:

{
  flake.nixosModules.transmission-web-app = { ... }: {
    webApps.transmission = {
      name = "Transmission";
      url = "http://192.168.1.100:9095";
      icon = "transmission";
      browser = "chromium-lan";
    };
  };
}
