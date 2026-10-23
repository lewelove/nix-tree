{ ... }:

{
  flake.nixosModules.chromium = { pkgs, lib, config, ... }:
    let
      fetchExtension = { id, hash }: let
        crx = pkgs.fetchurl {
          url = "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3&prodversion=${lib.versions.major pkgs.ungoogled-chromium.version}&x=id%3D${id}%26installsource%3Dondemand%26uc";
          name = "${id}.crx";
          sha256 = hash;
        };
      in {
        inherit id;
        drv = pkgs.runCommand "ext-${id}" { nativeBuildInputs = [ pkgs.unzip ]; } ''
          unzip ${crx} -d $out || true
        '';
      };

      extensions = {
        ublock-origin = rec {
          id = "mdcpogggagpjibjhpohkefbfgfaepcik";
          drv = pkgs.stdenv.mkDerivation rec {
            pname = "ublock-origin";
            version = "1.68.0";
            src = pkgs.fetchurl {
              url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
              hash = "sha256-lpb7CN2QbnH10gD+EH7YUptQMri1kLTUz0nTvxMgEOM=";
            };
            nativeBuildInputs = [ pkgs.unzip ];
            unpackPhase = "unzip $src -d .";
            installPhase = "mkdir -p $out; cp -r uBlock0.chromium/* $out/";
          };
        };

        sponsorblock = fetchExtension {
          id = "mnjggcdmjocbbbhaepdhchncahnbgone";
          hash = "sha256-nE5FE3Eo1jG8sT1KYjVl8JRbmAiyhN8IZObHsAIb0wY=";
        };
      };

      trustedOrigins = "http://vscode.localhost,http://vellum.localhost,http://qbittorrent.lab,http://excalidraw.localhost";

      commonArgs = [
        "--test-type"
        "--unsafely-treat-insecure-origin-as-secure=${trustedOrigins}"
        "--load-extension=${extensions.ublock-origin.drv}"
        "--extension-mime-request-handling=always-prompt-for-install"
        "--no-default-browser-check"
        "--restore-last-session"
        "--force-dark-mode"
        "--hide-scrollbars"
        "--hide-fullscreen-exit-ui"
        "--disable-features=BlockInsecurePrivateNetworkRequests,WaylandWpColorManagerV1"
        "--force-color-profile=srgb"
      ];

      chromiumWrapper = pkgs.writeShellScriptBin "chromium-browser" ''
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

      config.hm = {
        programs.chromium = {
          enable = true;
          package = pkgs.ungoogled-chromium;
          commandLineArgs = commonArgs;
        };

        systemd.user.services.chromium-service = {
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
