{ ... }:

{
  flake.nixosModules.bitwarden = { ... }: {
    services.flatpak.packages = [
      "com.bitwarden.desktop"
    ];
  };
}
