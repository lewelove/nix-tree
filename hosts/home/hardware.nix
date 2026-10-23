{ pkgs, id, ... }: {
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usbhid"
      "usb_storage"
      "uas"
      "sd_mod"
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [
      "kvm-intel"
      "msr"
    ];
    boot.extraModulePackages = [ ];

    swapDevices = [ ];
    zramSwap.enable = true;

    nixpkgs.hostPlatform = "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = true;

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/aace99ed-5d25-4cf6-98a2-631459ae5fa2";
      fsType = "btrfs";
      options = [
        "subvol=@"
        "compress=zstd"
        "noatime"
        "discard=async"
        "space_cache=v2"
      ];
    };

    fileSystems."/home" = {
      device = "/dev/disk/by-uuid/aace99ed-5d25-4cf6-98a2-631459ae5fa2";
      fsType = "btrfs";
      options = [
        "subvol=@home"
        "compress=zstd"
        "noatime"
        "discard=async"
        "space_cache=v2"
      ];
    };

    fileSystems."/nix" = {
      device = "/dev/disk/by-uuid/aace99ed-5d25-4cf6-98a2-631459ae5fa2";
      fsType = "btrfs";
      options = [
        "subvol=@nix"
        "compress=zstd"
        "noatime"
        "discard=async"
        "space_cache=v2"
      ];
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/6125-B937";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

    fileSystems."/run/media/${id.user}/1000xhome" = {
      device = "/dev/disk/by-uuid/27b9a1ab-0bb3-4e2f-bc9b-7c4a227dbb2f";
      fsType = "btrfs";
      options = [
        "nofail"
        "compress=zstd"
        "noatime"
        "space_cache=v2"
        "x-gvfs-show"
      ];
    };

    fileSystems."/run/media/${id.user}/500" = {
      device = "/dev/disk/by-uuid/8ad89f3d-6953-4ee7-b6bd-8e1a61e07e87";
      fsType = "btrfs";
      options = [
        "nofail"
        "compress=zstd"
        "noatime"
        "space_cache=v2"
        "x-gvfs-show"
      ];
    };

    fileSystems."/run/media/${id.user}/250x1" = {
      device = "/dev/disk/by-uuid/e7b47531-8e65-4096-be54-ca0648b0fe62";
      fsType = "btrfs";
      options = [
        "nofail"
        "compress=zstd"
        "noatime"
        "space_cache=v2"
        "x-gvfs-show"
      ];
    };

    fileSystems."/run/media/${id.user}/2000" = {
      device = "/dev/disk/by-uuid/e2873f44-a0b2-4c05-9e8a-d14e9cade796";
      fsType = "btrfs";
      options = [
        "nofail"
        "compress=zstd"
        "noatime"
        "space_cache=v2"
        "x-gvfs-show"
      ];
    };

    fileSystems."/mnt/servers/1000xlab" = {
      device = "192.168.1.100:/mnt/1000xlab";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
        "x-systemd.idle-timeout=600"
      ];
    };

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
