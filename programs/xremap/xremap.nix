{ ... }:

{
  flake.nixosModules.xremap = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.xremap ];

    hm = { pkgs, config, ... }: {
      link.".config/xremap" = ./.config/xremap;

      systemd.user.services.xremap = {
        Unit = {
          Description = "xremap keyboard remapper";
          After = [ "default.target" ];
        };
        Service = {
          ExecStart = "${pkgs.xremap}/bin/xremap --watch=device ${config.home.homeDirectory}/.config/xremap/config.yml";
          Restart = "always";
          RestartSec = "3s";
        };
        Install.WantedBy = [ "default.target" ];
      };
    };
  };
}
