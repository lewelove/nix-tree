{ ... }:

{
  flake.nixosModules.nvim = { pkgs, dotfiles, ... }: let
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

    hm.home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    hm.file.".config/nvim" = dotfiles.link ".config/nvim";
  };
}
