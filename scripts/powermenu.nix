{ ... }:

{
  flake.nixosModules.powermenu = { pkgs, ... }:
    let
      powermenu = pkgs.writeShellApplication {
        name = "powermenu";
        runtimeInputs = with pkgs; [ fuzzel systemd hyprshutdown ];
        text = ''
          OPTIONS=(
              "󰒲  Sleep"
              "󰑓  Reboot"
              "󰐥  Shutdown"
              "󰗼  Logout"
          )

          SELECTION=$(printf '%s\n' "''${OPTIONS[@]}" | fuzzel --dmenu --prompt="> " --lines 4 --width 32)

          case "$SELECTION" in
              *Sleep)
                  systemctl suspend
                  ;;
              *Reboot)
                  systemctl reboot
                  ;;
              *Shutdown)
                  systemctl poweroff
                  ;;
              *Logout)
                  hyprshutdown
                  ;;
          esac
        '';
      };
    in
    {
      environment.systemPackages = [ powermenu ];
    };
}
