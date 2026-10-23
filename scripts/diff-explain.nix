{ ... }:

{
  flake.nixosModules.diff-explain = { pkgs, ... }:
    let
      diff-explain = pkgs.writers.writeFishBin "diff-explain" ''
        begin
            echo '```diff'
            ${pkgs.git}/bin/git --no-pager diff --no-color $argv
            echo '```'
            echo '''
            echo 'Explain this PR, what it does, and how it improves/degrades things.'
        end | ${pkgs.wl-clipboard}/bin/wl-copy
      '';
    in
    {
      environment.systemPackages = [ diff-explain ];
    };
}
