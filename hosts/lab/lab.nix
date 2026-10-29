{ inputs, self, ... }:

{
  flake.nixosConfigurations.lab = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self; };
    modules = [
      inputs.disko.nixosModules.disko

      ./system.nix
      ./network.nix
      ./hardware.nix
      ./disko.nix
      ./packages.nix
      ./home-manager.nix
    ] ++ (with self.nixosModules; [
      id
      system
      cli-utils
      home-manager
      secrets

      openssh
      duckdns
      caddy
      authelia
      fail2ban
      v2raya
      xray-inbound
      starve-docs

      podman

      nfs
      qbittorrent
      jellyfin
      navidrome
      syncthing

      fish
      starship
      nvim
      git
      btop
      mpc

      cliphist-copy
      nrs
      sync
      try
      ytd
    ]);
  };
}
