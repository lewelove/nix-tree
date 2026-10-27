{ ... }:

{
  flake.nixosModules.slskd-web-app = { ... }: {
    webAppsLocal.slskd = {
      name = "Soulseek";
      url = "http://192.168.1.100:5030";
    };
  };
}
