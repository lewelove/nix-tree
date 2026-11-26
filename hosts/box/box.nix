{ inputs, self, ... }:

{
  flake.nixosConfigurations.box = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self; };
    modules = [
      inputs.microvm.nixosModules.microvm

      ./system.nix
      ./network.nix
      ./hardware.nix
      ./packages.nix
      ./microvm.nix
      ./home-manager.nix
    ] ++ (with self.nixosModules; [
      id
      dotfiles
      system
      cli-utils
      home-manager

      pi
      fish
      starship
      direnv
      git
      btop
      nvim
      devenv

      datamile
    ]);
  };
}
