{ ... }:

{
  flake.nixosModules.try = { pkgs, ... }:
    let
      try = pkgs.writers.writeFishBin "try" ''
        if test (count $argv) -eq 0
          exit 1
        end

        set -l pkg ""
        set -l rest

        if test (count $argv) -eq 1; and string match -q "* *" -- $argv[1]
          set -l split_args (string split -m 1 " " -- $argv[1])
          set pkg $split_args[1]
          if test (count $split_args) -gt 1
            set rest $split_args[2]
          end
        else
          set pkg $argv[1]
          if test (count $argv) -gt 1
            set rest $argv[2..-1]
          end
        end

        if test (count $rest) -gt 0
          exec nix run "nixpkgs#$pkg" -- $rest
        else
          exec nix run "nixpkgs#$pkg"
        end
      '';
    in
    {
      environment.systemPackages = [ try ];
    };
}
