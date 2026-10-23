{ ... }:

{
  flake.nixosModules.audio = { ... }: {
    hm = {
      link.".config/pipewire" = ./.config/pipewire;
      link.".config/wireplumber" = ./.config/wireplumber;
    };
  };
}
