{ ... }:

{
  flake.nixosModules.rust = { inputs, pkgs, ... }: {
    nixpkgs.overlays = [ inputs.rust-overlay.overlays.default ];

    environment.systemPackages = [
      (pkgs.rust-bin.stable.latest.default.override {
        extensions = [ "clippy" "rustfmt" "rust-src" "rust-analyzer" ];
        targets = [ "wasm32-unknown-unknown" ];
      })
    ];
  };
}
