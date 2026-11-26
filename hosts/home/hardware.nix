{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "msr" ];
  boot.extraModulePackages = [ ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = false;
    gfxmodeEfi = "1920x1080,2560x1440,auto";
  };

  boot.supportedFilesystems = [
    "btrfs"
    "nfs"
    "ntfs"
  ];

  boot.kernelParams = [
    "btusb.enable_autosuspend=0"
    "bluetooth.disable_ertm=1"
  ];

  swapDevices = [ ];
  zramSwap.enable = true;
  # Device size cap, not a reservation. zstd compresses ~3.6x here, so 100
  # buys ~4 GiB more usable memory than the 50 default without touching disk.
  zramSwap.memoryPercent = 100;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.uinput.enable = true;
  hardware.ksm.enable = true;

  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="uinput", MODE="0660"
    KERNEL=="event*", GROUP="input", MODE="0660"
  '';

  systemd.services.disable-bd-prochot = {
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
}
