{ ... }:

{
  flake.nixosModules.v2raya-web-app = { ... }: {
    webApps.v2raya = {
      name = "v2RayA";
      url = "http://192.168.1.100:2017";
      icon = "v2raya";
      browser = "chromium-lan";
    };
  };
}
