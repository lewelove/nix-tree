{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    stow
    gcc

    fastfetch

    rmpc

    lazygit
  ];
}
