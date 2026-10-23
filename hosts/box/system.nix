{ id, ... }:

{
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";

  system.stateVersion = "26.05";
  networking.hostName = "box";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.extraOptions = ''
    !include /home/${id.user}/.config/nix/nix.conf
  '';

  boot = {
    kernel.sysctl = {
      "vm.vfs_cache_pressure" = 50;
    };
    tmp = {
      useTmpfs = false;
      cleanOnBoot = true;
    };
  };
}
