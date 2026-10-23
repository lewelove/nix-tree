{ ... }:

{
  flake.nixosModules.hyprland = { pkgs, ... }: {
    programs.hyprland = {
      enable = true;
      withUWSM = false;
      xwayland.enable = true;
    };

    environment.systemPackages = with pkgs; [
      hyprshot
      hyprpicker
    ];

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
    };

    hm = {
      link.".config/hypr" = ./.config/hypr;

      systemd.user.targets.hyprland-session = {
        Unit = {
          Description = "Hyprland Compositor Session";
          Documentation = [ "man:systemd.special(7)" ];
          BindsTo = [ "graphical-session.target" ];
          Wants = [ "graphical-session-pre.target" ];
          After = [ "graphical-session-pre.target" ];
        };
      };
    };
  };
}
