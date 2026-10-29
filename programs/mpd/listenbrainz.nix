{ ... }:

{
  flake.nixosModules.listenbrainz = { pkgs, id, config, ... }:
    let
      listenbrainz-mpd-90-no4m = pkgs.listenbrainz-mpd.overrideAttrs (old: rec {
        pname = "listenbrainz-mpd-90-no4m";
        version = "git";
        src = pkgs.fetchFromGitea {
          domain = "codeberg.org";
          owner = "lewelove";
          repo = "listenbrainz-mpd-90-no4m";
          rev = "main";
          hash = "sha256-ZlELdjaJQukMZfDotmyuPW0S4D2zsPv++vQDOXnm/Yk=";
        };

        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          inherit src pname version;
          hash = "sha256-1x3F2TqNlqwfPUvLwU8ac4aEeEwpIy5gEyxRBC0Q5YM=";
        };
      });
    in
    {
      sops.secrets."listenbrainz-token" = { };

      sops.templates."listenbrainz-mpd.env" = {
        owner = id.user;
        mode = "0440";
        content = ''
          LISTENBRAINZ_TOKEN=${config.sops.placeholder."listenbrainz-token"}
        '';
      };

      webApps.listenbrainz = {
        name = "Listenbrainz";
        url = "https://listenbrainz.org";
        icon = "listenbrainz";
        browser = "chromium";
      };

      hm = { osConfig, ... }: {
        systemd.user.services.listenbrainz-mpd-90-no4m = {
          Unit = {
            Description = "ListenBrainz MPD Client (90% Threshold, No 4m Limit)";
            After = [ "mpd.service" ];
            Wants = [ "mpd.service" ];
          };
          Service = {
            ExecStart = "${listenbrainz-mpd-90-no4m}/bin/listenbrainz-mpd";
            Restart = "on-failure";
            RestartSec = "5s";
            EnvironmentFile = [ osConfig.sops.templates."listenbrainz-mpd.env".path ];
            Environment = [
              "LISTENBRAINZ_MPD_LOG=debug"
            ];
          };
          Install.WantedBy = [ "default.target" ];
        };
      };
    };
}
