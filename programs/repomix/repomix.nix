{ ... }:

{
  flake.nixosModules.repomix = { pkgs, dotfiles, ... }: {
    environment.systemPackages = [ pkgs.repomix ];

    hm.file.".config/repomix" = dotfiles.link ".config/repomix";
  };
}
