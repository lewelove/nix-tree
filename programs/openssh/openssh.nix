{ ... }:

{
  flake.nixosModules.openssh = { id, ... }: {
    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
    };

    users.users.${id.user}.openssh.authorizedKeys.keys = [
      id.sshKey
    ];
  };
}
