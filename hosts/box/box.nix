{ inputs, self, ... }:

{
  flake.nixosConfigurations.box = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self; };
    modules = [
      inputs.microvm.nixosModules.microvm

      ./system.nix
      ./network.nix
      ./packages.nix
      ./microvm.nix

      ({ id, ... }: {
        home-manager.users.${id.user}.home.activationGenerateGcRoot = false;
      })
    ] ++ (with self.nixosModules; [
      id
      system
      oxidation
      home-manager

      pi
      fish
      starship
      direnv
      git
      btop
      nvim
      devenv
    ]);
  };
}
