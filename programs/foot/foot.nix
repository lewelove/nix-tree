{ ... }:

{
  flake.nixosModules.foot = { pkgs, dotfiles, ... }: {
    environment.systemPackages = [ pkgs.foot ];

    hm.file.".config/foot" = dotfiles.link ".config/foot";
  };
}
