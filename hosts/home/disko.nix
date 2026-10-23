{ id, ... }:

{
  disko.devices.disk = {
    main = {
      device = "/dev/disk/by-uuid/aace99ed-5d25-4cf6-98a2-631459ae5fa2";
      type = "disk";
      destroy = false;
      content = {
        type = "btrfs";
        extraArgs = [ "-f" ];
        subvolumes = {
          "@" = {
            mountpoint = "/";
            mountOptions = [ "compress=zstd" "noatime" "discard=async" "space_cache=v2" ];
          };
          "@home" = {
            mountpoint = "/home";
            mountOptions = [ "compress=zstd" "noatime" "discard=async" "space_cache=v2" ];
          };
          "@nix" = {
            mountpoint = "/nix";
            mountOptions = [ "compress=zstd" "noatime" "discard=async" "space_cache=v2" ];
          };
        };
      };
    };

    boot = {
      device = "/dev/disk/by-uuid/6125-B937";
      type = "disk";
      destroy = false;
      content = {
        type = "filesystem";
        format = "vfat";
        mountpoint = "/boot";
        mountOptions = [ "fmask=0022" "dmask=0022" ];
      };
    };

    home1000 = {
      device = "/dev/disk/by-uuid/27b9a1ab-0bb3-4e2f-bc9b-7c4a227dbb2f";
      type = "disk";
      destroy = false;
      content = {
        type = "btrfs";
        extraArgs = [ "-f" ];
        mountpoint = "/run/media/${id.user}/1000xhome";
        mountOptions = [ "nofail" "compress=zstd" "noatime" "space_cache=v2" "x-gvfs-show" ];
      };
    };

    home500 = {
      device = "/dev/disk/by-uuid/8ad89f3d-6953-4ee7-b6bd-8e1a61e07e87";
      type = "disk";
      destroy = false;
      content = {
        type = "btrfs";
        extraArgs = [ "-f" ];
        mountpoint = "/run/media/${id.user}/500";
        mountOptions = [ "nofail" "compress=zstd" "noatime" "space_cache=v2" "x-gvfs-show" ];
      };
    };

    home250x1 = {
      device = "/dev/disk/by-uuid/e7b47531-8e65-4096-be54-ca0648b0fe62";
      type = "disk";
      destroy = false;
      content = {
        type = "btrfs";
        extraArgs = [ "-f" ];
        mountpoint = "/run/media/${id.user}/250x1";
        mountOptions = [ "nofail" "compress=zstd" "noatime" "space_cache=v2" "x-gvfs-show" ];
      };
    };

    home2000 = {
      device = "/dev/disk/by-uuid/e2873f44-a0b2-4c05-9e8a-d14e9cade796";
      type = "disk";
      destroy = false;
      content = {
        type = "btrfs";
        extraArgs = [ "-f" ];
        mountpoint = "/run/media/${id.user}/2000";
        mountOptions = [ "nofail" "compress=zstd" "noatime" "space_cache=v2" "x-gvfs-show" ];
      };
    };
  };
}
