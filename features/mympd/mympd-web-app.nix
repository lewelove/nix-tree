{ ... }:

{
  flake.nixosModules.mympd-web-app = { ... }: {
    webApps.mympd = {
      name = "myMPD";
      url = "http://192.168.1.100:666";
      icon = "mympd";
    };
  };
}
