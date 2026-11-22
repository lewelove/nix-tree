{ ... }:

{
  flake.nixosModules.photocraft = { pkgs, id, dotfiles, ... }:
    let
      runtimeLibs = with pkgs; [
        wayland
        wayland-protocols
        libxkbcommon
        libGL
        vulkan-loader
        libX11
        libXcursor
        libXi
        libXrandr
      ];

      photocraft-dev = pkgs.writeShellScriptBin "photocraft-dev" ''
        export WGPU_BACKEND="vulkan"
        export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath runtimeLibs}:/run/opengl-driver/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
        exec "/home/${id.user}/dev/cloned/photocraft/target/release/photocraft" "$@"
      '';
    in
    {
      environment.systemPackages = [ pkgs.photocraft photocraft-dev ];

      hm = {
        file.".config/photocraft" = dotfiles.link ".config/photocraft";

        xdg.desktopEntries.photocraft-dev = {
          name = "Photocraft Dev";
          genericName = "Image Editor";
          comment = "Dev build of PhotoCraft";
          exec = "photocraft-dev %F";
          icon = "ai.storyteller.photocraft";
          terminal = false;
          categories = [ "Graphics" "Photography" ];
        };
      };
    };
}
