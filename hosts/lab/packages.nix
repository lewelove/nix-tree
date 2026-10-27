{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    stow
    unzip
    gcc
    tree
    killall
    jq
    btop
    wol
    tcpdump
    net-tools
    wakeonlan

    starship
    fastfetch

    fzf

    mpc
    rmpc

    lazygit
  ];
}
