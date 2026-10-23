{ ... }:

{
  flake.nixosModules.nix-ld = { pkgs, ... }: {
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc.lib
        zlib
        vulkan-loader
        libGL
        libglvnd
        wayland
        wayland-protocols
        libxkbcommon
        libX11
        libXcursor
        libXi
        libXrandr
        libXrender
        libXinerama
        libXfixes
        libXext
        libxcb
        alsa-lib
        libpulseaudio
        pipewire
        openssl
        fontconfig
        freetype
      ];
    };
  };
}
