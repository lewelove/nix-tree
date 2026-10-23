{ ... }:

{
  flake.nixosModules.nfs = { ... }:
    let
      homeIp = "192.168.1.101";
      nfsPorts = "111,2049,4000,4001,4002";
    in
    {
      services.nfs.server = {
        enable = true;
        statdPort = 4000;
        lockdPort = 4001;
        mountdPort = 4002;

        exports = ''
          /mnt/1000xlab ${homeIp}(rw,nohide,insecure,no_subtree_check,all_squash,anonuid=1000,anongid=990)
        '';
      };

      networking.firewall.extraCommands = ''
        iptables -A INPUT -p tcp -s ${homeIp} -m multiport --dports ${nfsPorts} -j ACCEPT
        iptables -A INPUT -p udp -s ${homeIp} -m multiport --dports ${nfsPorts} -j ACCEPT
      '';
    };
}
