{ ... }:

{
  flake.nixosModules.imv = { pkgs, dotfiles, ... }: {
    environment.systemPackages = [ pkgs.imv ];

    hm.file.".config/imv" = dotfiles.link ".config/imv";
  };
}
