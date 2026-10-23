{ ... }:

{
  flake.nixosModules.transmission = { ... }: {
    webApps.transmission = {
      name = "Transmission";
      url = "http://192.168.1.100:9095";
      icon = "transmission";
    };
  };
}
