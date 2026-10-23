{ ... }:

{
  flake.nixosModules.discord = { ... }: {
    services.flatpak.packages = [
      "dev.vencord.Vesktop"
    ];
  };
}
