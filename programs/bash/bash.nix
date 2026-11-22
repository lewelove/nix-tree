{ ... }:

{
  flake.nixosModules.bash = { dotfiles, ... }: {
    hm.file.".bashrc" = dotfiles.link ".bashrc";
  };
}
