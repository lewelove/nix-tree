{ ... }:

{
  flake.nixosModules.chromium = import ./_nixos.nix;
  flake.homeModules.chromium = import ./_home.nix;
  flake.lib.mkChromium = import ./_wrapper.nix;
}
