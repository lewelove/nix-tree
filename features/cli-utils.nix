{ ... }:

{
  flake.nixosModules.cli-utils = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      ripgrep
      fd
      bat
      eza
      zoxide

      jq
      yq-go

      file
      less
      tree

      unzip
      zip
      psmisc

      curl
      wget
    ];

    programs.fzf = {
      fuzzyCompletion = true;
      keybindings = true;
    };
  };
}
