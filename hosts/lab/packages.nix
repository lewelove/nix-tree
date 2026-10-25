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

    ripgrep
    bat
    fd
    fzf
    zoxide
    eza

    mpc
    rmpc

    lazygit
  ];
}
