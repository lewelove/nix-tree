{ ... }:

{
  flake.nixosModules.networking = { ... }: {
    networking.hostName = "home";
    networking.networkmanager.enable = true;
    networking.nameservers = [
      "1.1.1.1"
      "9.9.9.9"
    ];
    networking.firewall.checkReversePath = "loose";
    networking.firewall.trustedInterfaces = [ "tun0" ];
  };
}
