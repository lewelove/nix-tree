{ ... }: {
  networking = {
    hostName = "home";
    networkmanager.enable = true;
    nameservers = [ "1.1.1.1" ];

    firewall = {
      checkReversePath = "loose";
      allowedTCPPorts = [ 80 8080 6600 666 2234 2235 2017 20170 20171 ];
      allowedUDPPorts = [ 9 2234 2235 20170 ];
    };
  };
}
