{ ... }:

{
  flake.nixosModules.syncthing = { id, ... }: {
    services.syncthing = {
      enable = true;
      user = id.user;
      group = "users";
      configDir = "/home/${id.user}/.config/syncthing";
      guiAddress = "0.0.0.0:8384";
      overrideDevices = false;
      overrideFolders = false;
    };

    networking.firewall = {
      allowedTCPPorts = [ 8384 22000 ];
      allowedUDPPorts = [ 22000 21027 ];
    };
  };
}
