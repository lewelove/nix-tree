{ inputs, ... }:

{
  flake.nixosModules.chromium-instances =
    { pkgs, lib, ... }:
    let
      extensions = inputs.ungoogled.lib.mkExtensions {
        inherit pkgs lib;
        settings.sponsorblock = {
          alreadyInstalled = true;
        };
      };
    in
    {
      chromium = {
        enable = true;

        baseArgs = [
          "--test-type"
          "--extension-mime-request-handling=always-prompt-for-install"
          "--no-default-browser-check"
          "--restore-last-session"
          "--force-dark-mode"
          "--hide-scrollbars"
          "--hide-fullscreen-exit-ui"
          "--force-color-profile=srgb"
        ];

        trustedOrigins = [
          "http://vscode.localhost"
          "http://vellum.localhost"
          "http://qbittorrent.lab"
          "http://excalidraw.localhost"
        ];

        disableFeatures = [
          "BlockInsecurePrivateNetworkRequests"
          "WaylandWpColorManagerV1"
        ];

        instances.default = {
          proxy = "socks5://192.168.1.100:20170";
          extensions = [
            extensions.ublock-origin
            extensions.sponsorblock
            extensions.youtube-theater
          ];
          backgroundService = true;
          serviceEnvironment = [ "XDG_CURRENT_DESKTOP=Hyprland" ];
        };

        instances.lan = {
          proxy = null;
          extensions = [ ];
        };
      };
    };
}
