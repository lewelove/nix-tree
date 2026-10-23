{ ... }:

{
  flake.nixosModules.navidrome = { ... }: {
    fileSystems."/var/lib/navidrome/music" = {
      device = "/mnt/1000xlab/backup-everything/FB2K/Library Historyfied!";
      fsType = "none";
      options = [ "bind" "ro" ];
    };

    fileSystems."/var/lib/navidrome/collections/bohemesss" = {
      device = "/mnt/1000xlab/backup-everything/FB2K/People Collection/bohemesss";
      fsType = "none";
      options = [ "bind" "ro" ];
    };

    fileSystems."/var/lib/navidrome/collections/chuvachonok" = {
      device = "/mnt/1000xlab/backup-everything/FB2K/People Collection/chuvachonok";
      fsType = "none";
      options = [ "bind" "ro" ];
    };

    services.navidrome = {
      enable = true;
      settings = {
        Address = "127.0.0.1";
        Port = 4533;
        MusicFolder = "/var/lib/navidrome/music";

        LogLevel = "info";
        DefaultTheme = "Dark";
        EnableDownloads = true;
        SessionTimeout = "720h";

        BaseUrl = "https://navidrome.lewelaboratory.duckdns.org";
      };
    };

    systemd.services.navidrome.serviceConfig = {
      SupplementaryGroups = [ "users" "wheel" "jellyfin" ];
      BindReadOnlyPaths = [
        "/var/lib/navidrome/collections/bohemesss"
        "/var/lib/navidrome/collections/chuvachonok"
      ];
    };
  };
}
