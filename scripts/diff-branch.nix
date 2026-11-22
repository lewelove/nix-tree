{ ... }:

{
  flake.nixosModules.diff-branch = { pkgs, ... }:
    let
      diff-branch = pkgs.writers.writeFishBin "diff-branch" ''
        set -l branch (${pkgs.git}/bin/git rev-parse --abbrev-ref HEAD)
        if test "$branch" = main
            echo 'diff-branch: already on main, checkout a branch first' >&2
            exit 1
        end
        ${pkgs.git}/bin/git --no-pager diff --no-color main...HEAD $argv | ${pkgs.wl-clipboard}/bin/wl-copy
      '';
    in
    {
      environment.systemPackages = [ diff-branch ];
    };
}
