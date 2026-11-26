{ pkgs, ... }:

{
  # Kernel OOM picks a small high-score process and leaves the box thrashing,
  # so kill the whole user session instead. core/system.nix only sets
  # mkDefault false, so plain true wins.
  systemd = {
    oomd.enable = true;
    sockets.systemd-oomd.enable = true;
    oomd.enableUserSlices = true;

    services.disable-bd-prochot = {
      description = "Disable BD PROCHOT CPU Throttling Bug";
      after = [
        "multi-user.target"
        "suspend.target"
        "hibernate.target"
        "hybrid-sleep.target"
      ];
      wantedBy = [
        "multi-user.target"
        "suspend.target"
        "hibernate.target"
        "hybrid-sleep.target"
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.msr-tools}/bin/wrmsr -a 0x1FC 0x38005c";
      };
    };
  };

  services = {
    blueman.enable = true;

    udev.extraRules = ''
      KERNEL=="uinput", GROUP="uinput", MODE="0660"
      KERNEL=="event*", GROUP="input", MODE="0660"
      KERNEL=="hidraw*", KERNELS=="*057E:2009*", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", KERNELS=="*045E:02FD*", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", KERNELS=="*045E:0B13*", MODE="0660", TAG+="uaccess"
    '';
  };

  programs = {
    ssh.startAgent = true;
    dconf.enable = true;
    fuse.userAllowOther = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
    FREETYPE_PROPERTIES = "truetype:interpreter-version=40 cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_MENU_PREFIX = "plasma-";
    GTK_USE_PORTAL = "1";
  };
}
