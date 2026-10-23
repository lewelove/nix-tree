{ ... }:

{
  flake.nixosModules.bash = { ... }: {
    hm.link.".bashrc" = ./.bashrc;
  };
}
