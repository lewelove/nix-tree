{ ... }:

{
  flake.nixosModules.steam-isp = { pkgs, ... }:
    let
      steam-isp = pkgs.writeShellScriptBin "steam-isp" ''
        exec isp steam "$@"
      '';
    in
    {
      environment.systemPackages = [ steam-isp ];

      hm = {
        xdg.desktopEntries.steam-isp = {
          name = "Steam (ISP Connection)";
          genericName = "Games Client";
          exec = "steam-isp %U";
          icon = "steam";
          terminal = false;
          categories = [ "Network" "Game" ];
        };
      };
    };
}
