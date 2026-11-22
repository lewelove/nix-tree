{ ... }:

{
  flake.nixosModules.rmpc = { pkgs, dotfiles, ... }: {
    environment.systemPackages = [ pkgs.rmpc ];
    hm.file.".config/rmpc" = dotfiles.link ".config/rmpc";
  };
}
