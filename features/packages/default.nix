{ inputs, ... }:

{
  flake.nixosModules.packages = { pkgs, ... }: {
    imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

    services.flatpak.enable = true;

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
      xremap
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
      repomix
      ripgrep
      bat
      fd
      fastfetch
      starship
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

    hm = {
      link = {
        ".bashrc" = ./.bashrc;
        ".scripts" = ./.scripts;
        ".applications" = ./.applications;
        ".config/starship.toml" = ./.config/starship.toml;
        ".config/mimeapps.list" = ./.config/mimeapps.list;
        ".config/repomix" = ./.config/repomix;
      };
    };
  };
}
