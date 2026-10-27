{ ... }:

{
  flake.nixosModules.chromium-isp = { pkgs, config, id, ... }:
    let
      chromium-isp = pkgs.writeShellScriptBin "chromium-isp" ''
        exec isp ${config.chromium.instances.isp.package}/bin/chromium-isp "$@"
      '';
    in
    {
      chromium.instances.isp = {
        userDataDir = "${config.users.users.${id.user}.home}/.config/chromium-isp";
        extraArgs = [
          "--disable-background-mode"
          "--reduce-user-agent-data-linux-platform-version"
          "--remove-client-hints"
        ];
      };

      environment.systemPackages = [ chromium-isp ];

      hm = {
        xdg.desktopEntries.chromium-isp = {
          name = "Chromium (ISP)";
          genericName = "Web Browser";
          comment = "Bypass the VPN via ISP gateway using a separate profile";
          exec = "chromium-isp %U";
          icon = "chromium";
          terminal = false;
          categories = [ "Network" "WebBrowser" ];
        };
      };
    };
}
