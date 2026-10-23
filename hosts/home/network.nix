{ id, pkgs, ... }: {
  programs.ssh.startAgent = true;

  hm.programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      lab = {
        HostName = "192.168.1.100";
        User = id.user;
      };
      box = {
        HostName = "127.0.0.1";
        Port = 2223;
        User = id.user;
      };
    };
  };

  fileSystems."/mnt/servers/1000xlab" = {
    device = "192.168.1.100:/mnt/1000xlab";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
    ];
  };

  networking = {
    hostName = "home";
    networkmanager.enable = true;
    nameservers = [ "1.1.1.1" ];

    firewall = {
      checkReversePath = "loose";
      allowedTCPPorts = [ 80 8080 6600 666 2234 2235 2017 20170 20171 ];
      allowedUDPPorts = [ 9 2234 2235 20170 ];
      trustedInterfaces = [ "tun0" ];
    };

    interfaces.enp3s0.wakeOnLan.enable = true;
  };

  systemd.services.wol-enp3s0 = {
    description = "Force Wake-on-LAN for enp3s0";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.ethtool}/bin/ethtool -s enp3s0 wol g";
      RemainAfterExit = true;
    };
  };

  services.v2raya = {
    enable = true;
    cliPackage = pkgs.xray;
  };

  systemd.services.v2raya.environment = {
    V2RAYA_ADDRESS = "0.0.0.0:2017";
    V2RAYA_V2RAY_BIN = "${pkgs.xray}/bin/xray";
  };

  environment.systemPackages = with pkgs; [
    ethtool
    xray
    v2ray-rules-dat
  ];
}
