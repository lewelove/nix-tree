{ inputs, ... }:

{
  flake.nixosModules.mpv = { pkgs, ... }:
    let
      stable = inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      environment.systemPackages = [
        (stable.mpv.override {
          mpv-unwrapped = stable.mpv-unwrapped.override {
            sdl2Support = true;
          };
        })
      ];

      webApps.mpv-wiki = {
        name = "Mpv Wiki";
        url = "https://mpv.io/manual/stable/";
      };

      hm.link.".config/mpv" = ./.config/mpv;
    };
}
