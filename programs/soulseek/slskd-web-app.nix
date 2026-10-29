{ ... }:

{
  flake.nixosModules.slskd-web-app = { ... }: {
    webApps.slskd = {
      name = "Soulseek";
      url = "http://192.168.1.100:5030";
      browser = "chromium-lan";
    };
  };
}
