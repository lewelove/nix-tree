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

      home-manager
      hyprland

      # Host Specific
      home-hardware
    ];
  };
}
