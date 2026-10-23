{ ... }:

{
  flake.nixosModules.ayugram = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.ayugram-desktop ];
  };
}
