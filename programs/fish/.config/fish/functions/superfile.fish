function superfile --description 'superfile + cd on quit'
     command superfile $argv

     set -l lastdir "$HOME/.local/state/superfile/lastdir"
     if test -f "$lastdir"
         source "$lastdir"
         rm -f -- "$lastdir"
     end
end
