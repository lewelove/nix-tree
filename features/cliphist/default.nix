{ ... }:

{
  flake.nixosModules.cliphist = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.cliphist ];

    hm = {
      systemd.user.services.cliphist = {
        Unit = {
          Description = "Cliphist Daemon";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch cliphist store";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      link.".config/cliphist" = ./.config/cliphist;
    };
  };
}
