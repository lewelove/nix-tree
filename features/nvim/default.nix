{ self, ... }:

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

  flake.nixosModules.nvim-gui = { pkgs, ... }: let
    nvl = pkgs.writeShellScriptBin "nvl" ''
      exec ${pkgs.alacritty}/bin/alacritty --class "nvim" -e ${pkgs.neovim}/bin/nvim "$@"
    '';

    desktopItem = pkgs.makeDesktopItem {
      name = "nvl";
      desktopName = "Neovim (Launcher)";
      genericName = "Text Editor";
      comment = "Edit text files in Neovim";
      exec = "nvl %F";
      icon = "nvim";
      terminal = false;
      categories = [
        "Utility"
        "TextEditor"
        "Development"
      ];
    };
  in {
    imports = [
      self.nixosModules.nvim
    ];

    environment.systemPackages = [
      nvl
      desktopItem
    ];
  };
}
