{ ... }:

{
  flake.nixosModules.home-scripts = { ... }: {
    hm.link.".scripts" = ./.scripts;
  };
}
