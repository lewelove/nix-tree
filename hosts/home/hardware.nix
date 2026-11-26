{ config, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "uas" "sd_mod" ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-intel" "msr" ];
    extraModulePackages = [ ];
    supportedFilesystems = [
      "btrfs"
      "nfs"
      "ntfs"
    ];
    kernelParams = [
      "btusb.enable_autosuspend=0"
      "bluetooth.disable_ertm=1"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = false;
        gfxmodeEfi = "1920x1080,2560x1440,auto";
      };
    };
  };

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    uinput.enable = true;
    ksm.enable = true;

    bluetooth = {
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

    graphics.enable = true;

    nvidia = {
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    };
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
    cpufreq = {
      min = 3600000;
      max = 3600000;
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Device size cap, not a reservation. zstd compresses ~3.6x here, so 100
  # buys ~4 GiB more usable memory than the 50 default without touching disk.
  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };
}
