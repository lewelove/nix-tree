{ config, ... }:

{
  hardware.nvidia = {
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  environment.sessionVariables = {
    WGPU_BACKEND = "vulkan";
    WLR_DRM_NO_ATOMIC = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GL_FSA_MODE = "0";
    __GL_AA_MODE = "0";
    __GL_MAX_FRAMES_ALLOWED = "0";
  };
}
