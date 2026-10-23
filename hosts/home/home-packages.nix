{ ... }:

{
  flake.nixosModules.home-packages = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      wget
      unzip
      gcc
      tree
      tree-sitter
      killall
      jq
      jaq
      yq-go
      ydotool
      wtype
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

      fuzzel
      mako
      libnotify
      awww
      nemo
      hyprshot
      hyprpicker
      wl-clipboard
      gnome-calculator
      gnome-clocks
      nicotine-plus
      peazip
      marktext
      zoxide
      tor-browser

      foot
      kitty
      btop
      ripgrep
      bat
      fd
      fastfetch
      tmux
      hyperfine
      lazygit
      git-filter-repo
      taplo
      yazi
      eza
      devenv
      yt-dlp
      monolith
      android-tools

      python3
      rustup

      distrobox

      imv
      mpc
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
  };
}
