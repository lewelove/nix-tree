{ inputs, ... }:

{
  flake.nixosModules.mpv = { pkgs, dotfiles, ... }:
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
        browser = "chromium";
      };

      hm.file.".config/mpv" = dotfiles.link ".config/mpv";
    };
}
