{ ... }:

{
  flake.nixosModules.quickshell = { pkgs, dotfiles, ... }: {
    hm = {
      systemd.user.services.quickshell = {
        Unit = {
          Description = "Quickshell Desktop Shell";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.quickshell}/bin/quickshell -p %h/.config/quickshell/hypr-ref/shell.qml";
          Restart = "on-failure";
          Environment = [
            "QSG_DISTANCEFIELD_ANTIALIASING=subpixel"
          ];
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      file.".config/quickshell" = dotfiles.link ".config/quickshell";
    };
  };
}
