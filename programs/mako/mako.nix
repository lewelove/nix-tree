{ ... }:

{
  flake.nixosModules.mako = { pkgs, dotfiles, ... }: {
    environment.systemPackages = [ pkgs.mako ];

    hm.file.".config/mako" = dotfiles.link ".config/mako";
  };
}
