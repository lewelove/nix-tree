{ id, config, lib, pkgs, ... }:

let
  kernelAtLeast = lib.versionAtLeast config.boot.kernelPackages.kernel.version;

  sharedProjects = [
    "cloned"
    "people"

    "datamile"
    "ungoogled-flake"
  ];

  # Mounted at the same path the host uses. Cargo bakes the workspace path into
  # build-script output, so a second spelling of the same tree makes the shared
  # target/ rebuild the C-heavy dependency chain on every switch of side.
  mkDevShare = name: {
    microvm.shares = [
      {
        proto = "virtiofs";
        tag = "dev-${name}";
        source = "/home/${id.user}/dev/${name}";
        mountPoint = "/home/${id.user}/dev/${name}";
      }
    ];

    systemd.tmpfiles.rules = [
      "d /home/${id.user}/dev 0755 ${id.user} users -"
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
    mem = 6144;

    storeDiskType = "erofs";

    # Stock builder copies the whole closure because a symlink in it dangles in
    # the sandbox. See ./store-disk.nix.
    storeDisk = lib.mkForce (import ./store-disk.nix { inherit config lib pkgs; });

    # This image is rebuilt from scratch on every switch. lz4hc (the upstream
    # default) compresses at about 40 MB/s per core; lz4 is roughly ten times
    # faster and makes the image about 10% bigger. Same flags otherwise.
    storeDiskErofsFlags =
      [ "-zlz4" ]
      ++ lib.optional (kernelAtLeast "5.16") "-Eztailpacking"
      ++ lib.optional (kernelAtLeast "6.1") "-Efragments";

    shares = [
      {
        proto = "virtiofs";
        tag = "nix-tree";
        source = id.repoPath;
        mountPoint = id.repoPath;
      }
      {
        proto = "virtiofs";
        tag = "dotfiles";
        source = "/home/${id.user}/dotfiles";
        mountPoint = "/home/${id.user}/dotfiles";
      }
      {
        proto = "virtiofs";
        tag = "home-box";
        source = "/home/${id.user}/virtual/box";
        mountPoint = "/home/${id.user}";
      }
      {
        proto = "virtiofs";
        tag = "music-library";
        source = "/run/media/${id.user}/1000xhome/backup-everything/FB2K/Library Historyfied!";
        mountPoint = "/mnt/library";
        readOnly = true;
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
