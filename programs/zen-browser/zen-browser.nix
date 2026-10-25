{ self, ... }:

{
  flake.nixosModules.zen-browser = { ... }: {
    hm = { inputs, pkgs, lib, ... }: let
      ublockOrigin = self.lib.ublockOrigin { inherit pkgs lib; };
    in {
      imports = [ inputs.zen-browser.homeModules.beta ];

      programs.zen-browser = {
        enable = true;

        policies = ublockOrigin.policies.zen;

        profiles.default.presets.betterfox.enable = true;
        profiles.default.presets.arkenfox.enable = true;
      };
    };
  };
}
