{ ... }:

{
  flake.nixosModules.starship = { pkgs, dotfiles, ... }: {
    environment.systemPackages = [ pkgs.starship ];

    hm.file.".config/starship.toml" = dotfiles.link ".config/starship.toml";
  };
}
