{ self, ... }:

{
  flake.nixosModules.chromium-instances =
    { pkgs, lib, ... }:
    let
      ublockOrigin = self.lib.ublockOrigin { inherit pkgs lib; };

      sponsorblock = self.lib.sponsorblock {
        inherit pkgs lib;
        settings = {
          alreadyInstalled = true;
        };
      };

      youtubeTheater = pkgs.runCommand "youtube-theater-extension" { } ''
        mkdir -p $out
        cp ${./extensions/youtube-theater}/manifest.json $out/manifest.json
        cp ${./extensions/youtube-theater}/background.js $out/background.js

        ${pkgs.jq}/bin/jq -e . $out/manifest.json > /dev/null
      '';

      extensions = [
        ublockOrigin.extensions.chromium
        sponsorblock.extensions.chromium
        youtubeTheater
      ];
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

        policies = {
          ublock-origin = ublockOrigin.policies.chromium;
          sponsorblock = sponsorblock.policies.chromium;
        };

        instances.default = {
          proxy = "socks5://192.168.1.100:20170";
          inherit extensions;
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
