{ ... }:

{
  flake.nixosModules.qutebrowser = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.qutebrowser ];
  };
}
