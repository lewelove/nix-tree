{ ... }:

{
  flake.nixosModules.slskd = { config, id, ... }: {
    fileSystems."/var/lib/slskd/music" = {
      device = "/mnt/1000xlab/backup-everything/FB2K/Library Historyfied!";
      fsType = "none";
      options = [ "bind" "ro" ];
    };

    sops.secrets."slskd/password" = { };
    sops.secrets."slskd/web-app-password" = { };

    sops.templates."slskd.env" = {
      mode = "0640";
      group = "slskd";
      restartUnits = [ "slskd.service" ];
      content = ''
        SLSKD_SLSK_USERNAME=${id.user}
        SLSKD_SLSK_PASSWORD=${config.sops.placeholder."slskd/password"}
        SLSKD_USERNAME=${id.user}
        SLSKD_PASSWORD=${config.sops.placeholder."slskd/web-app-password"}
      '';
    };

    services.slskd = {
      enable = true;
      environmentFile = config.sops.templates."slskd.env".path;
      openFirewall = true;

      settings = {
        soulseek = {
          listen_port = 50300;
          description = "350GB music library, open ports, online 24/7, look inside";
        };

        shares = {
          directories = [
            "/var/lib/slskd/music"
          ];
          filters = [
            "\\.(?!(flac|png|jpe?g|log|cue)$)[a-zA-Z0-9]+$"
            "(^|[\\\\/])\\.[^\\\\/]+$"
            "(^|[\\\\/])Blind Faith - Blind Faith([\\\\/]|$)"
          ];
        };

        directories = {
          downloads = "/mnt/1000xlab/downloads/slskd/";
        };

        transfers = {
          upload = {
            slots = 16;
          };
          download.slots = 3;
        };

        web = {
          port = 5030;
          https.disabled = true;
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 5030 ];
  };
}
