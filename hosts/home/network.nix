{ ... }: {
  networking = {
    hostName = "home";
    networkmanager.enable = true;
    nameservers = [ "1.1.1.1" ];

    firewall = {
      checkReversePath = "loose";
      # No service in this repo owns these.
      allowedTCPPorts = [ 80 8080 2234 2235 ];
      allowedUDPPorts = [ 9 2234 2235 ];
    };
  };
}
