{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    zoxide
    eza
    yazi
    rustup
    python3
    fd
    ripgrep
    nh
  ];
}
