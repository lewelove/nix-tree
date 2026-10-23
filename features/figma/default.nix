{ ... }:

{
  flake.nixosModules.figma = { pkgs, ... }: {
    webApps.figma = {
      name = "Figma";
      url = "https://figma.com";
      icon = "figma";
    };

    hm = {
      systemd.user.services.figma-agent = {
        Unit = {
          Description = "Figma Agent for Linux";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.figma-agent}/bin/figma-agent";
          Restart = "on-failure";
          RestartSec = "5s";
          Environment = [ "BIND=127.0.0.1:44950" ];
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      link.".config/figma-agent" = ./.config/figma-agent;
    };
  };
}
