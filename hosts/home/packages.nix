{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      ydotool
      wev
      xhost
      pulseaudio
      gnome-disk-utility
      sshfs
      mesa-demos
      waffle
      apitrace
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
      tor-browser

      fastfetch
      tmux
      hyperfine
      git-filter-repo
      taplo
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
}
