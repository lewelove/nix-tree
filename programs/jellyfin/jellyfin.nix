{ ... }:

{
  flake.nixosModules.jellyfin = { id, ... }: {
    services.jellyfin = {
      enable = true;
      openFirewall = false;
    };

    users.users.jellyfin.extraGroups = [ "torrents" ];
    users.users.${id.user}.extraGroups = [ "jellyfin" ];
  };
}
