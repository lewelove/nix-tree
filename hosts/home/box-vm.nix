{ inputs, self, config, id, ... }:

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
  imports = [
    inputs.microvm.nixosModules.host
  ];

  boot.kernelModules = [ "kvm-intel" ];

  networking.firewall.allowedTCPPorts = [ 2223 ];

  hm.programs.ssh.settings."box" = {
    hostname = "127.0.0.1";
    port = 2223;
    user = id.user;
  };

  systemd.tmpfiles.rules = [
    "d /home/${id.user}/virtual/box 0755 ${id.user} users -"
    "d /home/${id.user}/virtual/box/.config/nix 0755 ${id.user} users -"
    "d /home/${id.user}/dev 0755 ${id.user} users -"
  ] ++ (map (name: "d /home/${id.user}/dev/${name} 0755 ${id.user} users -") sharedProjects);

  sops.templates."box-nix-access-tokens" = {
    path = "/home/${id.user}/virtual/box/.config/nix/nix.conf";
    owner = id.user;
    group = "users";
    mode = "0644";
    content = ''
      access-tokens = github.com=${config.sops.placeholder."github-token"}
    '';
  };

  microvm.vms.box = {
    autostart = true;
    specialArgs = { inherit inputs self; };
    config = {
      imports = [
        ../box/system.nix
        ../box/network.nix
        ../box/packages.nix
        ../box/user.nix

        self.nixosModules.id
        self.nixosModules.user
        self.nixosModules.home-manager

        self.nixosModules.fish
        self.nixosModules.starship
        self.nixosModules.direnv
        self.nixosModules.git
        self.nixosModules.btop
        self.nixosModules.nvim
        self.nixosModules.devenv

        ({ id, ... }: {
          home-manager.users.${id.user}.home.activationGenerateGcRoot = false;
        })
      ] ++ (map mkDevShare sharedProjects);

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
    };
  };
}
