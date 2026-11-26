{ id, lib, ... }:

{
  system.stateVersion = lib.mkForce "25.11";

  security = {
    acme = {
      acceptTerms = true;
      defaults.email = id.email;
    };

    sudo.wheelNeedsPassword = true;
  };

  systemd = {
    oomd.enable = true;
    sockets.systemd-oomd.enable = true;
  };

  services = {
    getty.autologinUser = lib.mkForce null;
    logrotate.enable = lib.mkForce true;
  };

  documentation = {
    enable = lib.mkForce true;
    man.enable = lib.mkForce true;
    man.cache.enable = lib.mkForce true;
    nixos.enable = lib.mkForce true;
  };

  users.users.${id.user} = {
    uid = lib.mkForce 1000;
    initialPassword = "lab";
  };
}
