{ self, ... }:

{
  flake.nixosModules.chromium = { pkgs, lib, config, ... }:
    let
      ublockOrigin = self.lib.ublockOrigin { inherit pkgs lib; };

      extensions = {
        sponsorblock = {
          drv = pkgs.stdenv.mkDerivation {
            pname = "sponsorblock";
            version = "6.1.7";
            src = pkgs.fetchurl {
              url = "https://github.com/ajayyy/SponsorBlock/releases/download/6.1.7/ChromeExtension.zip";
              hash = "sha256-fI49yLXlYLSAro798o9PEQH84MwyQ0Viozaonkli7aM=";
            };
            nativeBuildInputs = [ pkgs.unzip ];
            dontUnpack = true;
            installPhase = ''
              runHook preInstall
              mkdir -p $out
              unzip -q $src -d $out
              runHook postInstall
            '';
          };
        };
      };

      trustedOrigins = "http://vscode.localhost,http://vellum.localhost,http://qbittorrent.lab,http://excalidraw.localhost";

      baseArgs = [
        "--test-type"
        "--unsafely-treat-insecure-origin-as-secure=${trustedOrigins}"
        "--extension-mime-request-handling=always-prompt-for-install"
        "--no-default-browser-check"
        "--restore-last-session"
        "--force-dark-mode"
        "--hide-scrollbars"
        "--hide-fullscreen-exit-ui"
        "--disable-features=BlockInsecurePrivateNetworkRequests,WaylandWpColorManagerV1"
        "--force-color-profile=srgb"
      ];

      loadedExtensions = [
        ublockOrigin.extensions.chromium
        extensions.sponsorblock.drv
      ];

      commonArgs = baseArgs ++ [
        "--load-extension=${lib.concatMapStringsSep "," toString loadedExtensions}"
      ];

      chromiumWrapper = pkgs.writeShellScriptBin "chromium-browser" ''
        set -euo pipefail

        profile="''${XDG_CONFIG_HOME:-$HOME/.config}/chromium"
        for arg in "$@"; do
          case "$arg" in
            --user-data-dir=*) profile="''${arg#--user-data-dir=}" ;;
          esac
        done

        prefs="$profile/Default/Preferences"
        mkdir -p "$(dirname "$prefs")"

        # --load-extension extensions land as unpacked extensions, which Chromium
        # disables (DISABLE_UNSUPPORTED_DEVELOPER_EXTENSION) unless the
        # extensions.ui.developer_mode pref is set: extension_service.cc:595.
        # The ExtensionDeveloperModeSettings policy can only disallow, never
        # allow, so preseed the pref. Idempotent: no write once it is true.
        if [ -f "$prefs" ]; then
          if ! ${pkgs.jq}/bin/jq -e '.extensions.ui.developer_mode == true' "$prefs" >/dev/null 2>&1; then
            ${pkgs.jq}/bin/jq '.extensions.ui.developer_mode = true' "$prefs" > "$prefs.tmp"
            mv "$prefs.tmp" "$prefs"
          fi
        else
          printf '%s\n' '{"extensions":{"ui":{"developer_mode":true}}}' > "$prefs"
        fi

        exec ${pkgs.ungoogled-chromium}/bin/chromium \
          ${lib.strings.escapeShellArgs commonArgs} \
          "$@" >/dev/null 2>&1
      '';
    in
    {
      options.chromium = lib.mkOption {
        type = lib.types.package;
        default = chromiumWrapper;
        description = "Wrapped Chromium package used for web apps";
      };

      config = {
        environment.etc."chromium/policies/managed/ublock-origin.json".text =
          builtins.toJSON ublockOrigin.policies.chromium;

        hm.programs.chromium = {
          enable = true;
          package = pkgs.ungoogled-chromium;
          commandLineArgs = commonArgs;
        };

        hm.systemd.user.services.chromium-service = {
          Unit = {
            Description = "Chromium Background Service";
            PartOf = [ "graphical-session.target" ];
            After = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = "${config.chromium}/bin/chromium-browser --silent-launch";
            Restart = "on-failure";
            RestartSec = "5s";
            Environment = [ "XDG_CURRENT_DESKTOP=Hyprland" ];
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };
    };
}
