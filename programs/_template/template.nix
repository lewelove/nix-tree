{ ... }:

{
  flake.nixosModules.template = { ... }: {
    webApps.template = {
      name = "TEMPLATE";
      url = "https://TEMPLATE";
      icon = "TEMPLATE";
    };
  };
}
