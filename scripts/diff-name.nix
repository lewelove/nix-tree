{ ... }:

{
  flake.nixosModules.diff-name = { pkgs, ... }:
    let
      diff-name = pkgs.writers.writeFishBin "diff-name" ''
        begin
            echo '```diff'
            ${pkgs.git}/bin/git --no-pager diff --no-color $argv
            echo '```'
            echo '''
            echo 'Explain this commit concisely and give it a message.'
        end | ${pkgs.wl-clipboard}/bin/wl-copy
      '';
    in
    {
      environment.systemPackages = [ diff-name ];
    };
}
