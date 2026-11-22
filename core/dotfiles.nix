{ ... }:

{
  flake.nixosModules.dotfiles = { lib, pkgs, ... }:
    let
      # User-defined strings live here and nowhere else.
      # This is a writable checkout of the dotfiles repo, and it must exist at
      # this exact path on every host that uses `dotfiles.link`.
      dotfilesPath = "/home/lewelove/dotfiles";

      slug = rel: lib.replaceStrings [ "/" "." ] [ "-" "" ] rel;

      # Store path that is a symlink to the live worktree entry.
      link = rel: pkgs.runCommandLocal "dotfiles-link-${slug rel}" { } ''
        ln -s ${dotfilesPath}/${rel} $out
      '';

      # Store path that is a read-only copy of the worktree entry.
      pin = rel: lib.cleanSourceWith {
        name = "dotfiles-pin-${slug rel}";
        src = /. + "${dotfilesPath}/${rel}";
      };
    in
    {
      _module.args.dotfiles = { inherit link pin dotfilesPath; };
    };
}
