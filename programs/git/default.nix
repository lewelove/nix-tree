{ self, ... }:

{
  flake.nixosModules.git = { pkgs, id, ... }: let
    lg = pkgs.writeShellScriptBin "lg" ''
      exec ${pkgs.lazygit}/bin/lazygit "$@"
    '';
  in {
    environment.systemPackages = [
      lg
    ];

    programs.git = {
      enable = true;
      config = {
        user = {
          name = id.user;
          email = id.email;
        };
        init.defaultBranch = "main";
        safe.directory = "*";
      };
    };
  };
}

