{ ... }:

{
  flake.nixosModules.nvim = { pkgs, ... }: let
    nv = pkgs.writeShellScriptBin "nv" ''
      exec ${pkgs.neovim}/bin/nvim "$@"
    '';
  in {
    environment.systemPackages = [
      pkgs.neovim
      pkgs.tree-sitter
      pkgs.gcc
      nv
    ];

    hm.link.".config/nvim" = ./.config/nvim;
  };
}
