{ ... }:

{
  flake.nixosModules.wrap-paste = { pkgs, ... }:
    let
      wrap-paste = pkgs.writeShellApplication {
        name = "wrap-paste";
        runtimeInputs = [ pkgs.wtype ];
        text = ''
          wtype -k Return
          wtype '```'
          wtype -k Return

          sleep 0.2

          wtype -M ctrl v -m ctrl

          sleep 0.1

          wtype -k Return
          wtype '```'
          wtype -k Return
        '';
      };
    in
    {
      environment.systemPackages = [ wrap-paste ];
    };
}
