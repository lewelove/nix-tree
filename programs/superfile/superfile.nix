{ ... }:

{
  flake.nixosModules.superfile = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.superfile ];

    hm.link.".config/superfile" = ./.config/superfile;
  };
}
