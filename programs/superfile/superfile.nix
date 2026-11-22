{ ... }:

{
  flake.nixosModules.superfile = { pkgs, dotfiles, ... }: {
    environment.systemPackages = [ pkgs.superfile ];

    hm.file.".config/superfile" = dotfiles.link ".config/superfile";
  };
}
