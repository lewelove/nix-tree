{ ... }:

{
  flake.nixosModules.fish = { ... }: {
    programs.fish.enable = true;

    hm.link.".config/fish" = ./.config/fish;
  };
}
