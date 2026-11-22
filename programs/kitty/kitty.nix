{ ... }:

{
  flake.nixosModules.kitty = { pkgs, dotfiles, ... }: {
    environment.systemPackages = [ pkgs.kitty ];

    hm.file.".config/kitty" = dotfiles.link ".config/kitty";
  };
}
