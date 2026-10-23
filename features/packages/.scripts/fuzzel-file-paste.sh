    #!${pkgs.fish}/bin/fish

    set TOML_FILE "/home/${identity.username}/.config/fuzzel/file-paste.toml"

    if not test -f "$TOML_FILE"
        exit 1
    end

    set KEYS (${pkgs.yq-go}/bin/yq -p=toml '.files | keys | .[]' "$TOML_FILE")

    set SELECTION (printf "%s\n" $KEYS | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt="File Paste: ")

    if test -z "$SELECTION"
        exit 0
    end

    set PATHS (env sel="$SELECTION" ${pkgs.yq-go}/bin/yq -p=toml '.files[strenv(sel)] | .[]' "$TOML_FILE")

    set URI_LIST
    for path in $PATHS
        if test -z "$path"
            continue
        end

        set expanded_path (string replace -r '^~' "/home/${identity.username}" "$path")

        if not string match -r '^/' "$expanded_path" >/dev/null
            set expanded_path (${pkgs.coreutils}/bin/realpath "$expanded_path")
        end

        if not string match -r '^file://' "$expanded_path" >/dev/null
            set expanded_path "file://$expanded_path"
        end

        set -a URI_LIST "$expanded_path"
    end

    if set -q URI_LIST[1]
        string join \n $URI_LIST | ${pkgs.wl-clipboard}/bin/wl-copy -t text/uri-list
        sleep 0.1
        ${pkgs.wtype}/bin/wtype -M ctrl -M shift v -m shift -m ctrl
    end

