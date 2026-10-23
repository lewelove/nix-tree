{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      wget
      unzip
      tree
      killall
      jq
      ydotool
      wev
      xhost
      pulseaudio
      gnome-disk-utility
      sshfs
      tcpdump
      mkcert
      mesa-demos
      waffle
      apitrace
      openssl
      cryptsetup
      brightnessctl
      ddcutil
      toml2json
      qrencode
      gparted

      libnotify
      nemo
      wl-clipboard
      gnome-calculator
      gnome-clocks
      nicotine-plus
      peazip
      zoxide
      tor-browser

      ripgrep
      bat
      fd
      fastfetch
      tmux
      hyperfine
      git-filter-repo
      taplo
      yazi
      eza
      yt-dlp
      monolith
      android-tools

      python3
      rustup

      distrobox

      flac
      flac2all
      mediainfo
      imagemagick
      roomeqwizard
      transmission_4
      ffmpeg
      intermodal
      aria2
      umu-launcher

      nwg-look
      adwaita-icon-theme

      nh
      nvd
      nix-output-monitor

      love
    ];

    programs.dconf.enable = true;
    programs.fuse.userAllowOther = true;

    programs.fzf = {
      fuzzyCompletion = true;
      keybindings = true;
    };
}
