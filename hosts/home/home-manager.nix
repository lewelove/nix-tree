{ id, ... }: {
  hm.programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      # lab = {
      #   HostName = "192.168.1.100";
      #   User = id.user;
      # };
      box = {
        HostName = "127.0.0.1";
        Port = 2223;
        User = id.user;
      };
    };
  };

  home-manager.users.${id.user} = { config, ... }: {
    xdg.configFile."user-dirs.conf".text = "enabled=False";

    xdg.userDirs = {
      enable = true;
      setSessionVariables = true;
      createDirectories = false;

      desktop = "${config.home.homeDirectory}/Documents";
      music = "${config.home.homeDirectory}/Documents";
      pictures = "${config.home.homeDirectory}/Documents";
      publicShare = "${config.home.homeDirectory}/Documents";
      templates = "${config.home.homeDirectory}/Documents";
      videos = "${config.home.homeDirectory}/Documents";

      download = "/run/media/${id.user}/1000xhome/downloads";
    };
  };
}
