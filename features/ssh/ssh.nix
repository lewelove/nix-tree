{ ... }:

{
  flake.nixosModules.ssh = { id, ... }: {
    programs.ssh.startAgent = true;

    hm = {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings."lab" = {
          HostName = "192.168.1.100";
          User = id.user;
        };
      };
    };
  };
}
