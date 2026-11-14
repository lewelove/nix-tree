{ ... }:

{
  flake.nixosModules.v2raya-web-app = { ... }: {
    webApps.v2raya = {
      name = "v2RayA";
      url = "http://127.0.0.1:2017";
      icon = "v2raya";
      browser = "chromium-lan";
    };
  };
}
