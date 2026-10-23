set -g fish_greeting

if status is-interactive

  starship init fish | source

  set -g fish_color_command green

  # function starship_newline --on-event fish_prompt
  #     if set -q _starship_rendered
  #         echo ""
  #     end
  #     set -g _starship_rendered 1
  # end

  alias clr="set -e _starship_rendered; clear"
  alias clear="set -e _starship_rendered; command clear"

  alias ls "eza"
  alias x+ "chmod +x"
  alias e "superfile"

  alias clients "hyprctl clients | rg -A 3 'class'"
  alias mip "curl ip-api.com"

  abbr -a rs "systemctl --user restart"
  abbr -a sp "systemctl --user stop"
  abbr -a st "systemctl --user status"
  abbr -a jl "journalctl --user -fu"

  abbr -a rss "sudo systemctl restart"
  abbr -a sps "sudo systemctl stop"
  abbr -a sts "systemctl status"
  abbr -a jls "journalctl -fu"

  abbr -a b "clr && build && notify-send 'Built!'"

  abbr -a dv "devenv shell"

  abbr -a lab "ssh lab"
  abbr -a box "ssh box"

  alias sync "git-sync-bin"
  alias c "wl-copy"

  if type -q devenv
    devenv hook fish | source
    # devenv hook fish | sed 's/devenv shell/devenv shell --quiet/g' | source
  end

  function lowmtime
    find . -type f -printf '%T@ %Tb %Td %TY %p\n' | sort -n | head -1 | string replace -r '^(\d+)\.\d+' \'\$1\'
  end

  abbr -a dl "dale"
  abbr -a dx "dale x"
  abbr -a cl "dale x collect"

  alias vellcro="/home/lewelove/dev/.archived/vellcro/rust/target/release/vellcro"
  alias mute "/home/lewelove/dev/mute/rust/target/release/mute"

  alias discid "/home/lewelove/dev/album_curation/rsdiscid/target/release/rsdiscid"
  alias albumset "/home/lewelove/dev/album_curation/album_setup/.build/bin/album_setup"
  alias albumw "/home/lewelove/dev/album_curation/album_write/.build/bin/album_write"
  alias albumspl "/home/lewelove/dev/album_curation/album_split/.build/bin/album_split"
  alias albumresample "/home/lewelove/dev/album_curation/album_to_44100hz/.build/bin/album_to_44100hz"
  alias mbid "/home/lewelove/dev/album_curation/mbid/.build/bin/mbid"
  alias mb-manifest "/home/lewelove/dev/album_curation/mb_manifest/.build/bin/mb_manifest"
  alias cover-resize "/home/lewelove/dev/album_curation/cover_resize/.build/bin/cover_resize"
  alias cover-save "/home/lewelove/dev/album_curation/cover_save.fish"
  alias flac2webm "/home/lewelove/dev/album_curation/flac2webm.fish"

  function distrobox
      if contains $argv[1] create rm stop assemble
          systemd-run --user --scope --unit=distrobox-setup distrobox $argv
      else
          command distrobox $argv
      end
  end

  zoxide init fish --cmd z | source
  source ~/.config/fish/completions/z.fish

  if test (hostname) = "home"
    set -gx SOPS_AGE_KEY (ssh-to-age -private-key -i ~/.ssh/id_ed25519 2>/dev/null)
  end

end
