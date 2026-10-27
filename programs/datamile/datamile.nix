{ ... }:

{
  flake.nixosModules.datamile = { pkgs, id, ... }:
    let
      datamile-cmd = pkgs.writeShellScriptBin "datamile" ''
        case "$1" in
          ui)
            cd "/home/${id.user}/dev/datamile/web-app" && exec ${pkgs.bun}/bin/bun run dev
            ;;
          *)
            exec "/home/${id.user}/dev/datamile/target/release/datamile" "$@"
            ;;
        esac
      '';
    in
    {
      environment.systemPackages = [ pkgs.bun datamile-cmd ];

      webAppsLocal.datamile = {
        name = "Datamile";
        url = "http://localhost:4173";
        icon = "datamile";
      };

      webAppsLocal.datamile-dev = {
        name = "Datamile Dev";
        url = "http://localhost:5173";
        icon = "datamile";
      };

      hm.link.".config/datamile" = ./.config/datamile;
    };
}
