{ ... }:

{
  flake.nixosModules.rebuild = { pkgs, lib, config, id, ... }:
    let
      proxy = config.rebuild.proxy;
      proxyEnv = lib.optionalAttrs (proxy != "") {
        http_proxy = proxy;
        https_proxy = proxy;
        all_proxy = proxy;
        no_proxy = "localhost,127.0.0.1,::1";
      };

      mkRebuild = name: action: done: pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = with pkgs; [ nh coreutils gum ];
        text = ''
          r() { gum style --foreground 1 "$*"; }
          g() { gum style --foreground 2 "$*"; }
          y() { gum style --foreground 3 "$*"; }
          b() { gum style --foreground 4 "$*"; }

          # Flake input fetching (git/libcurl) and nh's own requests run as this
          # user, so they need the proxy here. Substitution downloads come from
          # nix-daemon, which gets the same env via config.rebuild.proxy.
          PROXY="''${REBUILD_PROXY:-${proxy}}"
          if [ -n "$PROXY" ]; then
            hp="''${PROXY#*://}"
            hp="''${hp%%/*}"
            hp="''${hp##*@}"
            if (exec 3<>"/dev/tcp/''${hp%%:*}/''${hp##*:}") 2>/dev/null; then
              export http_proxy="$PROXY" https_proxy="$PROXY" all_proxy="$PROXY"
              export no_proxy="localhost,127.0.0.1,::1" NO_PROXY="localhost,127.0.0.1,::1"
            else
              echo "$(y "[~] ")" "proxy $PROXY unreachable, downloading direct"
            fi
          fi

          TARGET_HOST="''${1:-$(hostname)}"

          if [ ! -d "${id.repoPath}/hosts/$TARGET_HOST" ]; then
            echo "$(r "[!] ")" "Error: Host directory ${id.repoPath}/hosts/$TARGET_HOST does not exist in ${id.repoPath}"
            exit 1
          fi

          cd "${id.repoPath}" || exit 1

          git add .

          export NH_FLAKE="${id.repoPath}"

          if nh os ${action} "${id.repoPath}" --hostname "$TARGET_HOST"; then
              echo
              gum join --horizontal "$(g "[+] ")" "Configuration for " "$(b "$TARGET_HOST")" " ${done}."
          else
              echo
              gum join --horizontal "$(r "[!] ")" "Build failed."
              exit 1
          fi
        '';
      };
    in
    {
      options.rebuild.proxy = lib.mkOption {
        type = lib.types.str;
        default = "socks5h://127.0.0.1:20170";
        description = "Proxy nix downloads go through (socks5h:// or http://). Empty disables.";
      };

      config = {
        # The client env above only covers fetching; the daemon does substitutions.
        systemd.services.nix-daemon.environment = proxyEnv;

        environment.systemPackages = [
          (mkRebuild "nrs" "switch" "applied")
          (mkRebuild "nrb" "boot" "added to boot")
        ];
      };
    };
}
