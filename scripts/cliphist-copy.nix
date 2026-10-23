{ ... }:

{
  flake.nixosModules.cliphist-copy = { pkgs, ... }:
    let
      cliphist-copy = pkgs.writers.writeFishBin "cliphist-copy" ''
        set -l tmp (${pkgs.coreutils}/bin/mktemp)

        if test (count $argv) -gt 0
            string join \n -- $argv > $tmp
        else
            ${pkgs.coreutils}/bin/cat > $tmp
        end

        test -s $tmp; or begin
            ${pkgs.coreutils}/bin/rm -f $tmp
            exit 0
        end

        set -l first_line (${pkgs.coreutils}/bin/head -n 1 $tmp)
        if string match -qr '^[0-9]+\t' -- "$first_line"
            set -l id (string split \t -- "$first_line")[1]
            set -l decoded (${pkgs.coreutils}/bin/mktemp)
            if ${pkgs.cliphist}/bin/cliphist decode "$id" > $decoded 2>/dev/null; and test -s $decoded
                ${pkgs.coreutils}/bin/mv -f $decoded $tmp
            else
                ${pkgs.coreutils}/bin/rm -f $decoded
            end
        end

        set -l is_file_list 1
        set -l uris

        set -l lines (${pkgs.coreutils}/bin/head -c 65536 $tmp)
        if test -z "$lines"
            set is_file_list 0
        end

        for line in (string split \n -- $lines | string trim)
            test -n "$line"; or continue

            set -l path (string trim -c "'" -- "$line" | string trim -c '"')
            if string match -q 'file://*' -- "$path"
                set path (string replace -r '^file://' "" -- "$path")
                set path (string replace -r '^localhost/' '/' -- "$path")
                set path (string unescape --style=url -- "$path")
            end

            set path (string replace -r '^~' "$HOME" -- "$path")

            if not test -e "$path"; or test -d "$path"
                set is_file_list 0
                break
            end

            set -l abs (${pkgs.coreutils}/bin/realpath -- "$path")
            set -a uris "file://$abs"
        end

        if test $is_file_list -eq 1; and test (count $uris) -gt 0
            string join \r\n -- $uris | ${pkgs.wl-clipboard}/bin/wl-copy -t text/uri-list
        else
            ${pkgs.wl-clipboard}/bin/wl-copy < $tmp
        end

        ${pkgs.coreutils}/bin/rm -f $tmp
      '';
    in
    {
      environment.systemPackages = [ cliphist-copy ];
    };
}
