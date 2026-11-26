{ id, ... }:

{
  nix.extraOptions = ''
    !include /home/${id.user}/.config/nix/nix.conf
  '';

  # networkd must not reap sing-box's policy rules and routes.
  systemd = {
    network.config.networkConfig.ManageForeignRoutingPolicyRules = false;

    # networkd restart wipes tun0 rules; restart sing-box with it.
    services.sing-box = {
      after = [
        "network.target"
        "nss-lookup.target"
        "network-online.target"
        "systemd-networkd.service"
      ];
      requires = [ "systemd-networkd.service" ];
      partOf = [ "systemd-networkd.service" ];
    };

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
