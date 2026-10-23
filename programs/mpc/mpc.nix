{ ... }:

{
  flake.nixosModules.mpc = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.mpc ];
  };
}
