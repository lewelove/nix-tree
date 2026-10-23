{ ... }:

{
  flake.nixosModules.v2raya = { pkgs, ... }: {
    services.v2raya = {
      enable = true;
      cliPackage = pkgs.xray;
    };

    networking.firewall = {
      allowedTCPPorts = [ 2017 20170 20171 ];
      allowedUDPPorts = [ 20170 ];
    };

    environment.systemPackages = with pkgs; [
      xray
      v2ray-rules-dat
    ];

    systemd.services.v2raya.environment = {
      V2RAYA_ADDRESS = "0.0.0.0:2017";
      V2RAYA_V2RAY_BIN = "${pkgs.xray}/bin/xray";
    };
  };
}
