{ ... }:

{
  flake.nixosModules.oxidation = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      ripgrep
      fd
      bat
      eza
      zoxide
      yazi
    ];
  };
}
