{ inputs, self, ... }:

{
  flake.nixosConfigurations.home = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = with self.nixosModules; [

      # Core
      id
      system
      user
      boot

      # Modules
      home-system
      nix-ld

      home-packages
      home-scripts
      home-manager
      secrets
      web-apps

      bash
      fish
      starship
      mimeapps
      repomix
      xremap

      ssh
      git
      nvim-gui
      zen-browser

      ayugram
      bitwarden
      discord
      obs
      qutebrowser

      cliphist
      thunar
      quickshell
      dale
      figma
      photopea
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
      mpv

      # Host Specific
      home-hardware
      home-syncthing
    ];
  };
}
