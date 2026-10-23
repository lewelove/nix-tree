{ ... }:

{
  flake.nixosModules.dale = { pkgs, id, ... }:
    let
      dale-cmd = pkgs.writeShellScriptBin "dale" ''
        case "$1" in
          ui)
            cd "/home/${id.user}/dev/dale/web-app" && exec ${pkgs.bun}/bin/bun run dev
            ;;
          *)
            exec "/home/${id.user}/dev/dale/target/release/dale" "$@"
            ;;
        esac
      '';
    in
    {
      environment.systemPackages = [ pkgs.bun dale-cmd ];

      webApps.dale = {
        name = "Dale";
        url = "http://localhost:4173";
        icon = "dale";
      };

      webApps.dale-dev = {
        name = "Dale Dev";
        url = "http://localhost:5173";
        icon = "dale";
      };

      hm.link.".config/dale" = ./.config/dale;
    };
}
