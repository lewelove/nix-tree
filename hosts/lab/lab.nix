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
      dotfiles
      system
      cli-utils
      cli-networking
      home-manager
      secrets

      openssh
      v2raya

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
      rebuild
      sync
      try
      ytd
    ]);
  };
}
