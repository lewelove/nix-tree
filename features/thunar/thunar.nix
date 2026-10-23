{ ... }:

{
  flake.nixosModules.thunar = { pkgs, ... }: {
    programs.thunar.enable = true;

    services.gvfs.enable = true;
    services.tumbler.enable = true;
    services.udisks2.enable = true;

    systemd.user.services.thunar = {
      description = "Thunar File Manager Daemon";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.thunar}/bin/thunar --daemon";
        Restart = "always";
      };
    };

    hm.link.".config/Thunar" = ./.config/Thunar;
  };
}
