complete -c z -e
complete -c z -f -a '(
    for p in (zoxide query --list -- (commandline -pt) 2>/dev/null)
        string replace -r "^$HOME" "~" -- $p
    end
)'
