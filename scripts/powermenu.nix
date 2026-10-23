{ ... }:

{
  flake.nixosModules.powermenu = { pkgs, ... }:
    let
      powermenu = pkgs.writeShellApplication {
        name = "powermenu";
        runtimeInputs = with pkgs; [ fuzzel systemd hyprland ];
        text = ''
          OPTIONS="󰒲  Sleep\n󰑓  Reboot\n󰐥  Shutdown\n󰗼  Logout"

          SELECTION=$(echo -e "$OPTIONS" | fuzzel --dmenu --prompt="> " --lines 4 --width 32)

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
                  if command -v hyprshutdown >/dev/null 2>&1; then
                      hyprshutdown
                  else
                      hyprctl dispatch exit
                  fi
                  ;;
          esac
        '';
      };
    in
    {
      environment.systemPackages = [ powermenu ];
    };
}
