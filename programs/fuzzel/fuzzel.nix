{ ... }:

{
  flake.nixosModules.fuzzel = { pkgs, ... }:
    let
      fuzzel-bookmarks = pkgs.writeShellApplication {
        name = "fuzzel-bookmarks";
        runtimeInputs = with pkgs; [ fuzzel gawk gnugrep xdg-utils coreutils ];
        text = ''
          FILE="$HOME/.config/fuzzel/bookmarks.txt"

          selection=$(awk -F'=' '{print $1}' "$FILE" | fuzzel --dmenu --prompt="Bookmark: ")

          [[ -z "$selection" ]] && exit 0

          line=$(grep "^$selection=" "$FILE")
          url="''${line#*=}"

          xdg-open "$url"
        '';
      };

      fuzzel-copy = pkgs.writeShellApplication {
        name = "fuzzel-copy";
        runtimeInputs = with pkgs; [ fuzzel wl-clipboard coreutils ];
        text = ''
          OPTIONS=(
            "Unix Epoch"
            "YYYYMMDD"
          )

          selection=$(printf "%s\n" "''${OPTIONS[@]}" | fuzzel --dmenu --prompt="Copy: " --width 20)

          [[ -z "$selection" ]] && exit 0

          case "$selection" in
              "YYYYMMDD")
                  echo -n "$(date +'%Y%m%d')" | wl-copy
                  ;;
              "Unix Epoch")
                  echo -n "$(date +%s)" | wl-copy
                  ;;
          esac
        '';
      };

      fuzzel-file-paste = pkgs.writers.writeFishBin "fuzzel-file-paste" ''
        set TOML_FILE "$HOME/.config/fuzzel/file-paste.toml"

        if not test -f "$TOML_FILE"
            exit 1
        end

        set -x TOML_FILE "$TOML_FILE"
        set JSON_DATA (${pkgs.nushell}/bin/nu -c 'open $env.TOML_FILE | get files | to json')

        set KEYS (echo "$JSON_DATA" | ${pkgs.jq}/bin/jq -r 'keys_unsorted | .[]')

        set SELECTION (printf "%s\n" $KEYS | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt="File Paste: ")

        if test -z "$SELECTION"
            exit 0
        end

        set RUN_CMD (echo "$JSON_DATA" | ${pkgs.jq}/bin/jq -r --arg sel "$SELECTION" '.[$sel].run')

        if test -n "$RUN_CMD" -a "$RUN_CMD" != "null"
            sh -c "$RUN_CMD"
            if test $status -ne 0
                exit 1
            end
        end

        set PATHS (echo "$JSON_DATA" | ${pkgs.jq}/bin/jq -r --arg sel "$SELECTION" '.[$sel].paste | .[]')

        for path in $PATHS
            if test -z "$path"
                continue
            end

            set expanded_path (string replace -r '^~' "$HOME" "$path")

            if not string match -r '^/' "$expanded_path" >/dev/null
                set expanded_path (${pkgs.coreutils}/bin/realpath "$expanded_path")
            end

            if not string match -r '^file://' "$expanded_path" >/dev/null
                set expanded_path "file://$expanded_path"
            end

            echo -n "$expanded_path" | ${pkgs.wl-clipboard}/bin/wl-copy -t text/uri-list
            sleep 0.1
            ${pkgs.wtype}/bin/wtype -M ctrl v -m ctrl
            sleep 0.1
        end
      '';
    in
    {
      environment.systemPackages = [
        fuzzel-bookmarks
        fuzzel-copy
        fuzzel-file-paste
      ];

      hm.link.".config/fuzzel" = ./.config/fuzzel;
    };
}
