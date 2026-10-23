{ ... }:

{
  flake.nixosModules.ytd = { pkgs, ... }:
    let
      ytd = pkgs.writers.writeFishBin "ytd" ''
        if test (count $argv) -eq 0
          echo "Usage: ytd <url> [options]"
          exit 1
        end

        mkdir -p $HOME/Videos
        exec ${pkgs.yt-dlp}/bin/yt-dlp --cookies-from-browser chromium -P $HOME/Videos $argv
      '';
    in
    {
      environment.systemPackages = [ ytd ];
    };
}
