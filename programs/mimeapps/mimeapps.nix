{ ... }:

{
  flake.nixosModules.mimeapps = { dotfiles, ... }: {
    hm.file.".config/mimeapps.list" = dotfiles.link ".config/mimeapps.list";
  };
}
