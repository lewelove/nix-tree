{ id, ... }:

let
  sharedProjects = [
    "cloned"
    "dale"
    "nix-tree"
  ];

  mkDevShare = name: {
    microvm.shares = [
      {
        proto = "virtiofs";
        tag = "dev-${name}";
        source = "/home/${id.user}/dev/${name}";
        mountPoint = "/mnt/dev/${name}";
      }
    ];

    systemd.tmpfiles.rules = [
      "d /home/${id.user}/dev 0755 ${id.user} users -"
      "L+ /home/${id.user}/dev/${name} - - - - /mnt/dev/${name}"
    ];
  };
in
{
  imports = map mkDevShare sharedProjects;

  microvm = {
    hypervisor = "qemu";
    qemu.extraArgs = [
      "-device"
      "virtio-balloon-pci,free-page-reporting=on"
    ];
    vcpu = 4;
    mem = 8192;

    storeDiskType = "erofs";

    shares = [
      {
        proto = "virtiofs";
        tag = "nix-config";
        source = id.repoPath;
        mountPoint = id.repoPath;
        readOnly = true;
      }
      {
        proto = "virtiofs";
        tag = "home-box";
        source = "/home/${id.user}/virtual/box";
        mountPoint = "/home/${id.user}";
      }
    ];

    volumes = [
      {
        image = "/var/lib/microvms/box/box-store-overlay.img";
        mountPoint = "/nix/.rw-store";
        size = 40960;
        fsType = "ext4";
        autoCreate = true;
      }
      {
        image = "/var/lib/microvms/box/box-nix-var.img";
        mountPoint = "/nix/var";
        size = 4096;
        fsType = "ext4";
        autoCreate = true;
      }
      {
        image = "/var/lib/microvms/box/box-tmp.img";
        mountPoint = "/tmp";
        size = 8192;
        fsType = "ext4";
        autoCreate = true;
      }
    ];

    writableStoreOverlay = "/nix/.rw-store";

    interfaces = [
      {
        type = "user";
        id = "usernet";
        mac = "02:00:00:00:00:01";
      }
    ];

    forwardPorts = [
      {
        from = "host";
        host.port = 2223;
        guest.port = 22;
      }
    ];
  };
}
