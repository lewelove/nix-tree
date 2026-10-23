{ ... }:

{
  flake.nixosModules.steam = { ... }: {
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    programs.gamemode.enable = true;

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
