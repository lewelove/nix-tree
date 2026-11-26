{ inputs, self, config, id, ... }:

{
  imports = [
    inputs.microvm.nixosModules.host
  ];

  networking.firewall.allowedTCPPorts = [ 2223 ];

  systemd.tmpfiles.rules = [
    "d /home/${id.user}/virtual/box 0755 ${id.user} users -"
    "d /home/${id.user}/virtual/box/.config/nix 0755 ${id.user} users -"
    "d /home/${id.user}/dev 0755 ${id.user} users -"
  ];

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
    flake = self;
    restartIfChanged = true;
  };
}
