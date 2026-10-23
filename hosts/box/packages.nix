{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    pi-coding-agent
    git
    zoxide
    eza
    yazi
    lazygit
    rustup
    python3
    fd
    ripgrep
    nh
  ];
}
