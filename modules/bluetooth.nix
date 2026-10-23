{ ... }:

{
  flake.nixosModules.bluetooth = { ... }: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
          AutoEnable = true;
          AutoConnect = true;
          UserspaceHID = true;
          ControllerMode = "bredr";
          Enable = "Source,Sink,Media,Socket";
        };
        Policy = {
          AutoEnable = true;
          ReconnectAttempts = 7;
          ReconnectInterval = 2;
        };
      };
    };

    services.blueman.enable = true;

    services.udev.extraRules = ''
      KERNEL=="hidraw*", KERNELS=="*057E:2009*", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", KERNELS=="*045E:02FD*", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", KERNELS=="*045E:0B13*", MODE="0660", TAG+="uaccess"
    '';
  };
}
