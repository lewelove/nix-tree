{ ... }:

{
  flake.nixosModules.datamile = { pkgs, id, dotfiles, ... }:
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

      hm.file.".config/datamile" = dotfiles.link ".config/datamile/main";
    };
}
