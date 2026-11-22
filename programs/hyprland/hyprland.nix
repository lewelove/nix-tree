{ ... }:

{
  flake.nixosModules.hyprland = { pkgs, id, dotfiles, ... }: {
    programs.hyprland = {
      enable = true;
      withUWSM = false;
      xwayland.enable = true;
    };

    # getty autologins on every tty, but the compositor should only come up on
    # the first tty1 login of each boot. /run is per-boot tmpfs; tmpfiles makes
    # a user-writable dir there, the login shell drops the marker.
    systemd.tmpfiles.rules = [ "d /run/hyprland-autostart 0755 ${id.user} users -" ];

    # NixOS splices loginShellInit into /etc/fish/config.fish verbatim, so it
    # must be fish, not bash. start-hyprland passes --watchdog-fd and restarts
    # Hyprland in safe mode after a crash. Other ttys stay plain shells.
    programs.fish.loginShellInit = ''
      if test (tty) = /dev/tty1
        and not set -q HYPRLAND_INSTANCE_SIGNATURE
        and not test -e /run/hyprland-autostart/started
        touch /run/hyprland-autostart/started
        exec start-hyprland
      end
    '';

    environment.systemPackages = with pkgs; [
      hyprshot
      hyprpicker
    ];

    # environment.sessionVariables.HYPRLAND_NO_SD_TARGET = "1";

    security.polkit.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config = {
        common.default = [ "gtk" ];
        hyprland.default = [ "hyprland" "gtk" ];
      };
    };

    webApps.hyprland-wiki = {
      name = "Hyprland Wiki";
      url = "https://wiki.hypr.land";
      browser = "chromium";
    };

    hm.file.".config/hypr" = dotfiles.link ".config/hypr";
  };
}
