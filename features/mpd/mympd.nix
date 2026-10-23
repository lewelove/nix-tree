{ ... }:

{
  flake.nixosModules.mympd = { ... }: {
    services.mympd = {
      enable = true;
      openFirewall = true;
      settings = {
        http_port = 666;
        http_host = "0.0.0.0";
      };
    };

    webApps.mympd = {
      name = "myMPD";
      url = "http://192.168.1.100:666";
      icon = "mympd";
    };
  };
}
