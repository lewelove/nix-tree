{ ... }:

{
  flake.nixosModules.starve-docs = { pkgs, id, ... }:
    let
      appDir = "/home/${id.user}/websites/starve-docs";
    in
    {
      environment.systemPackages = [ pkgs.bun ];

      systemd.services.starve-docs = {
        description = "Starve! Docs Bun Web Server";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          User = id.user;
          Group = "users";
          WorkingDirectory = appDir;
          ExecStart = "${pkgs.bun}/bin/bun run server.ts";
          Restart = "always";
          RestartSec = "3s";
          Environment = [
            "PORT=3005"
            "NODE_ENV=production"
          ];
        };
      };
    };
}
