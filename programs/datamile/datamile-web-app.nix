{ ... }:

{
  flake.nixosModules.datamile-web-app = { ... }: {
    webApps.datamile = {
      name = "Datamile";
      url = "http://localhost:4173";
      icon = "datamile";
      browser = "chromium-lan";
    };

    webApps.datamile-dev = {
      name = "Datamile Dev";
      url = "http://localhost:5173";
      icon = "datamile";
      browser = "chromium-lan";
    };
  };
}
