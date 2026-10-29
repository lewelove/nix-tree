{ inputs, self, ... }:

{
  flake.nixosConfigurations.home = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self; };
    modules = [
      inputs.disko.nixosModules.disko

      ./system.nix
      ./network.nix
      ./packages.nix
      ./hardware.nix
      ./disko.nix
      ./games.nix
      ./home-manager.nix
      ./box-vm.nix
    ] ++ (with self.nixosModules; [
      # Core
      id
      system

      # Modules
      cli-utils
      nix-ld
      isp
      theme

      # Network
      sing-box

      # Scripts
      cliphist-copy
      nrs
      sync
      try
      ytd
      ns
      nt
      change-wallpaper
      powermenu
      wrap-paste
      diff-explain
      diff-name
      diff-review

      home-manager
      secrets
      web-apps

      bash
      fish
      starship
      mimeapps
      repomix
      xremap
      fuzzel

      awww
      polkit-agent
      btop
      devenv
      direnv

      alacritty
      superfile
      photocraft
      mpc

      foot
      kitty
      mako
      audio
      imv

      git
      nvim-gui
      zen-browser
      pi

      ayugram
      bitwarden
      discord
      obs
      qutebrowser

      cliphist
      thunar
      quickshell
      datamile
      figma
      syncthing
      syncthing-web-app

      chromium-isp
      steam
      steam-isp

      hyprland
      mpd
      rmpc
      listenbrainz
      mympd
      mympd-web-app

      navidrome-web-app
      jellyfin-web-app
      qbittorrent-web-app
      slskd-web-app
      transmission-web-app
      v2raya-web-app
      youtube-web-app
      mpv
    ]);
  };
}
