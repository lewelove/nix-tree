{ inputs, self, ... }:

{
  flake.nixosConfigurations.home = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./system.nix
      ./network.nix
      ./packages.nix
      ./hardware.nix
    ] ++ (with self.nixosModules; [
      # Core
      id
      system
      user
      boot

      # Modules
      nix-ld
      isp

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
      mpv
    ]);
  };
}
