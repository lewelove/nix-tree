{ id, lib, ... }:

{
  boot.kernelModules = [ "tun" ];

  security.acme = {
    acceptTerms = true;
    defaults.email = id.email;
  };

  system.stateVersion = lib.mkForce "25.11";

  services.getty.autologinUser = lib.mkForce null;

  documentation = {
    enable = lib.mkForce true;
    man.enable = lib.mkForce true;
    man.cache.enable = lib.mkForce true;
    nixos.enable = lib.mkForce true;
  };

  services.logrotate.enable = lib.mkForce true;

  systemd.oomd.enable = true;
  systemd.sockets.systemd-oomd.enable = true;

  users.users.${id.user} = {
    uid = lib.mkForce 1000;
    initialPassword = "lab";
  };

  security.sudo.wheelNeedsPassword = true;
}
