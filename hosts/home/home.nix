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
      ./nvidia.nix
      ./disko.nix
      ./home-manager.nix
      ./microvm.nix

      inputs.ungoogled.nixosModules.default
    ] ++ (with self.nixosModules; [
      # Core
      id
      dotfiles
      system

      # Modules
      cli-utils
      cli-networking
      nix-ld
      isp
      theme

      # Network
      v2raya

      # Scripts
      cliphist-copy
      rebuild
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
      diff-branch

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
      rust

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

      cliphist
      thunar
      quickshell
      datamile
      syncthing
      syncthing-web-app

      chromium-instances
      chromium-isp
      steam
      steam-isp

      hyprland
      mpd
      rmpc
      listenbrainz
      mympd
      mympd-web-app

      datamile-web-app
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
