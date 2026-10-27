{ self, ... }:

{
  flake.nixosModules.chromium = { pkgs, lib, config, ... }:
    let
      ublockOrigin = self.lib.ublockOrigin { inherit pkgs lib; };
      sponsorblock = self.lib.sponsorblock {
        inherit pkgs lib;
        settings = { alreadyInstalled = true; };
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
        sponsorblock.extensions.chromium
      ];

      commonArgs = baseArgs ++ [
        "--load-extension=${lib.concatMapStringsSep "," toString loadedExtensions}"
      ];

      v2rayaSocksProxy = "socks5://192.168.1.100:20170";

      binaryName = name: if name == "default" then "chromium" else "chromium-${name}";

      instanceArgs = instance:
        commonArgs
        ++ lib.optional (instance.userDataDir != null) "--user-data-dir=${instance.userDataDir}"
        ++ lib.optional (instance.proxy != null) "--proxy-server=${instance.proxy}"
        ++ instance.extraArgs;

      mkWrapper = name: instance: pkgs.writeShellScriptBin (binaryName name) ''
        set -euo pipefail

        args=(${lib.strings.escapeShellArgs (instanceArgs instance)})
        profile="''${XDG_CONFIG_HOME:-$HOME/.config}/chromium"
        for arg in "''${args[@]}" "$@"; do
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
          "''${args[@]}" \
          "$@" >/dev/null 2>&1
      '';
    in
    {
      options.chromium.instances = lib.mkOption {
        default = {};
        description = "Chromium instances, each with its own flags";
        type = lib.types.attrsOf (lib.types.submodule ({ name, config, ... }: {
          options = {
            userDataDir = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Profile directory; null uses Chromium's default";
            };

            proxy = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Proxy to force, e.g. socks5://host:port; null adds no flag";
            };

            extraArgs = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
              description = "Additional command-line arguments";
            };

            package = lib.mkOption {
              type = lib.types.package;
              readOnly = true;
              description = "Browser package with this instance's flags baked in";
            };
          };

          config.package = mkWrapper name config;
        }));
      };

      config = {
        chromium.instances.default = {
          proxy = v2rayaSocksProxy;
        };

        environment.etc = lib.mapAttrs' (name: policy:
          lib.nameValuePair "chromium/policies/managed/${name}.json" {
            text = builtins.toJSON policy;
          }) {
            ublock-origin = ublockOrigin.policies.chromium;
            sponsorblock = sponsorblock.policies.chromium;
          };

        hm.programs.chromium = {
          enable = true;
          package = config.chromium.instances.default.package;
          commandLineArgs = [];
        };

        # The wrapper is a shell script, so it ships no .desktop file of its own.
        hm.xdg.desktopEntries.chromium = {
          name = "Chromium";
          genericName = "Web Browser";
          exec = "chromium %U";
          icon = "chromium";
          terminal = false;
          categories = [ "Network" "WebBrowser" ];
        };

        hm.systemd.user.services.chromium-service = {
          Unit = {
            Description = "Chromium Background Service";
            PartOf = [ "graphical-session.target" ];
            After = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = "${config.chromium.instances.default.package}/bin/chromium --silent-launch";
            Restart = "on-failure";
            RestartSec = "5s";
            Environment = [ "XDG_CURRENT_DESKTOP=Hyprland" ];
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };
    };
}
