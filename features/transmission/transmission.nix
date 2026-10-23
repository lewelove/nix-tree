{ ... }:

{
  flake.nixosModules.transmission = { ... }: {
    services.transmission = {
      enable = true;
      group = "torrents";
      settings = {
        umask = 2;
        download-dir = "/mnt/1000xlab/downloads/transmission";
        incomplete-dir-enabled = false;
        cache-size-mb = 1024;
        encryption = 1;
        peer-port = 54322;
        port-forwarding-enabled = false;
        rpc-bind-address = "0.0.0.0";
        rpc-port = 9095;
        rpc-whitelist-enabled = true;
        rpc-whitelist = "127.0.0.1,192.168.*.*,10.*.*.*";
        rpc-host-whitelist-enabled = false;
      };
    };

    networking.firewall = {
      allowedTCPPorts = [ 9091 54322 ];
      allowedUDPPorts = [ 54322 ];
    };
  };
}
