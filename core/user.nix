{ ... }:

{
  flake.nixosModules.user = { pkgs, id, ... }: {
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
