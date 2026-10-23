{ ... }:

{
  flake.nixosModules.zen-browser = { ... }: {
    hm = { inputs, ... }: {
      imports = [ inputs.zen-browser.homeModules.beta ];

      programs.zen-browser = {
        enable = true;

        profiles.default.presets.betterfox.enable = true;
        profiles.default.presets.arkenfox.enable = true;
      };
    };
  };
}
