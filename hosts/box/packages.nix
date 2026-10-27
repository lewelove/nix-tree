{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    rustup
    python3
    nh
  ];
}
