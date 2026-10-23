{ ... }:

{
  flake.nixosModules.qbittorrent = { id, ... }: {
    services.qbittorrent = {
      enable = true;
      webuiPort = 8081;
      torrentingPort = 54321;
      openFirewall = true;
      user = "qbittorrent";
      group = "torrents";
    };

    systemd.services.qbittorrent.serviceConfig = {
      UMask = "0002";
    };

    systemd.tmpfiles.rules = [
      "d /mnt/1000xlab 0775 ${id.user} torrents -"
      "d /mnt/1000xlab/downloads 2775 qbittorrent torrents -"
      "d /mnt/1000xlab/media 2775 qbittorrent torrents -"
    ];

    users.users.qbittorrent.uid = 993;
    users.groups.torrents.gid = 990;

    users.users.${id.user}.extraGroups = [ "torrents" ];
  };
}
