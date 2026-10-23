{ ... }: {
  hm = {
    services.syncthing = {
      enable = true;
      extraOptions = [
        "--gui-address=127.0.0.1:8384"
        "--no-browser"
      ];
    };
  };
}
