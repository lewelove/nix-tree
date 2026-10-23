{ ... }:

{
  flake.nixosModules.obs = { pkgs, ... }: {
    environment.systemPackages = [
      (pkgs.wrapOBS {
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          obs-pipewire-audio-capture
          obs-vkcapture
        ];
      })
    ];
  };
}
