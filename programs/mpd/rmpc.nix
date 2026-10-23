{ ... }:

{
  flake.nixosModules.rmpc = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.rmpc ];
    hm.link.".config/rmpc" = ./.config/rmpc;
  };
}
