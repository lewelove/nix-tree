{ ... }:

{
  flake.nixosModules.soulseek = { ... }: {
    webApps.soulseek = {
      name = "Soulseek";
      url = "http://192.168.1.100:5030";
    };
  };
}
