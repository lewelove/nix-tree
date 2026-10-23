{ ... }:

{
  flake.nixosModules.starship = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.starship ];

    hm.link.".config/starship.toml" = ./.config/starship.toml;
  };
}
