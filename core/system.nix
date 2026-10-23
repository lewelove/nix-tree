{ ... }:

{
  flake.nixosModules.system = { pkgs, id, ... }: {
    time.timeZone = "Europe/Moscow";
    i18n.defaultLocale = "en_US.UTF-8";

    documentation = {
      enable = false;
      man.enable = false;
      man.cache.enable = false;
      nixos.enable = false;
    };

    services.logrotate.enable = false;

    nixpkgs.config.allowUnfree = true;

    systemd.oomd.enable = false;
    systemd.sockets.systemd-oomd.enable = false;

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    system.stateVersion = "26.05";

    programs.fish.enable = true;

    users.users.${id.user} = {
      isNormalUser = true;
      uid = 1001;
      group = "users";
      extraGroups = [
        "networkmanager"
        "wheel"
        "input"
        "uinput"
        "i2c"
      ];
      shell = pkgs.fish;
      autoSubUidGidRange = true;
      openssh.authorizedKeys.keys = [
        id.sshKey
      ];
    };

    services.getty.autologinUser = id.user;
  };
}
