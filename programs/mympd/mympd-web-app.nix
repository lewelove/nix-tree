{ ... }:

{
  flake.nixosModules.mympd-web-app = { ... }: {
    webApps.mympd = {
      name = "myMPD";
      url = "http://192.168.1.101:666";
      icon = "mympd";
      browser = "chromium-lan";
    };
  };
}
