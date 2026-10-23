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
      environment
      networking
      nix-ld
      nvidia
      bluetooth
      virtualization

      packages
      home-manager
      secrets
      web-apps

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

      chromium-isp
      steam-isp

      hyprland
      mpd
      rmpc
      listenbrainz
      mympd

      navidrome
      soulseek
      transmission
      v2raya
      mpv

      # Host Specific
      home-hardware
    ];
  };
}
