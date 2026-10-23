{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    prismlauncher
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
