{ id, lib, ... }:

{
  home-manager.users.${id.user} = {
    home.stateVersion = lib.mkForce "25.05";
    fonts.fontconfig.enable = lib.mkForce false;
  };
}
