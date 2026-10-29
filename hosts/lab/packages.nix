{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    stow
    gcc
    wol
    tcpdump
    net-tools
    wakeonlan

    fastfetch

    rmpc

    lazygit
  ];
}
