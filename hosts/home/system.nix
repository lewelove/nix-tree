{ pkgs, config, ... }:

{
  environment.sessionVariables = {
    WGPU_BACKEND = "vulkan";
    WLR_DRM_NO_ATOMIC = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
    FREETYPE_PROPERTIES = "truetype:interpreter-version=40 cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
    __GL_FSA_MODE = "0";
    __GL_AA_MODE = "0";
    __GL_MAX_FRAMES_ALLOWED = "0";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_MENU_PREFIX = "plasma-";
    GTK_USE_PORTAL = "1";
    EDITOR = "nvim";
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        AutoEnable = true;
        AutoConnect = true;
        UserspaceHID = true;
        ControllerMode = "bredr";
        Enable = "Source,Sink,Media,Socket";
      };
      Policy = {
        AutoEnable = true;
        ReconnectAttempts = 7;
        ReconnectInterval = 2;
      };
    };
  };

  services.blueman.enable = true;

  services.udev.extraRules = ''
    KERNEL=="hidraw*", KERNELS=="*057E:2009*", MODE="0660", TAG+="uaccess"
    KERNEL=="hidraw*", KERNELS=="*045E:02FD*", MODE="0660", TAG+="uaccess"
    KERNEL=="hidraw*", KERNELS=="*045E:0B13*", MODE="0660", TAG+="uaccess"
  '';

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };

  virtualisation.containers.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    extraPackages = [ pkgs.nvidia-container-toolkit ];
  };

  virtualisation.containers.containersConf.settings = {
    containers = {
      log_driver = "k8s-file";
    };
    storage = {
      driver = "btrfs";
    };
    engine = {
      runtime = "crun";
      events_logger = "file";
      cgroup_manager = "systemd";
    };
  };
}
