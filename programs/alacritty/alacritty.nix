{ ... }:

{
  flake.nixosModules.alacritty = { pkgs, dotfiles, ... }: {
    environment.systemPackages = [ pkgs.alacritty ];

    hm.file.".config/alacritty" = dotfiles.link ".config/alacritty";
  };
}
