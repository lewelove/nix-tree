{ inputs, ... }:

{
  flake.nixosModules.discord = { ... }: {
    imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

    services.flatpak.enable = true;
    services.flatpak.packages = [
      "dev.vencord.Vesktop"
    ];
  };
}
