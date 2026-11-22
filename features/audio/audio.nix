{ ... }:

{
  flake.nixosModules.audio = { dotfiles, ... }: {
    hm = {
      file.".config/pipewire" = dotfiles.link ".config/pipewire";
      file.".config/wireplumber" = dotfiles.link ".config/wireplumber";
    };
  };
}
