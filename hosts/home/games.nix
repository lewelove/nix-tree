{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    prismlauncher
    # rimsort
    # steamcmd
  ];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
    cpufreq = {
      min = 3600000;
      max = 3600000;
    };
  };
}
