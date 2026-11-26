{ id, ... }:

{
  nix.extraOptions = ''
    !include /home/${id.user}/.config/nix/nix.conf
  '';

  systemd = {
    tmpfiles.rules = [
      "d /home/${id.user}/.ssh 0700 ${id.user} users -"
      "d /nix/var/ssh 0700 root root -"
    ];
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    hostKeys = [
      {
        path = "/nix/var/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
