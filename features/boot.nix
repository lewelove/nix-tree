{ ... }:

{
  flake.nixosModules.boot = { pkgs, ... }: {
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = false;
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
  };
}
