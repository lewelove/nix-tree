{ ... }:

{
  flake.nixosModules.fish = { dotfiles, ... }: {
    programs.fish.enable = true;

    hm.file.".config/fish" = dotfiles.link ".config/fish";
  };
}
