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
  };
}
