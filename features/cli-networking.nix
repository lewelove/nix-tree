{ ... }:

{
  flake.nixosModules.cli-networking = { pkgs, id, ... }: {
    environment.systemPackages = with pkgs; [
      iproute2
      ethtool
      lsof

      tshark

      dnsutils
      doggo
      whois

      nmap
      mtr
      traceroute

      iperf3
      bandwhich

      xh
      socat
      arp-scan

      openssl
      mkcert

      wol
      wakeonlan
    ];

    programs.tcpdump.enable = true;
    programs.wireshark.enable = true;

    users.users.${id.user}.extraGroups = [ "wireshark" ];
  };
}
