{ self, lib, ... }:

{
  flake.nixosModules.web-apps = { config, pkgs, ... }:
    let
      appType = lib.types.attrsOf (lib.types.submodule {
        options = {
          name = lib.mkOption { type = lib.types.str; };
          url = lib.mkOption { type = lib.types.str; };
          icon = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
        };
      });

      # A desktop entry and a PATH command for every declaration.
      render = osConfig: instance: apps:
        let
          browser = osConfig.chromium.instances.${instance};
          browserBin = "${browser.package}/bin/${browser.binary}";

          entry = id: app: lib.nameValuePair id {
            inherit (app) name icon;
            exec = "${browserBin} --app=${app.url}";
            terminal = false;
          };

          command = id: app: lib.nameValuePair "${id}-web-app" (
            pkgs.writeShellScriptBin "${id}-web-app" ''
              exec ${browserBin} --app=${lib.escapeShellArg app.url} "$@"
            ''
          );
        in
        {
          entries = lib.mapAttrs' entry apps;
          commands = lib.attrValues (lib.mapAttrs' command apps);
        };
    in
    {
      imports = [ self.nixosModules.chromium ];

      options.webApps = lib.mkOption {
        type = appType;
        default = {};
        description = "Web apps opened by the default Chromium instance";
      };

      options.webAppsLocal = lib.mkOption {
        type = appType;
        default = {};
        description = "Web apps opened by the LAN Chromium instance";
      };

      config = {
        # Entry ids become desktop file names, so they must not repeat across options.
        assertions = [
          {
            assertion =
              let
                ids = lib.flatten (map lib.attrNames [ config.webApps config.webAppsLocal ]);
              in
              lib.length ids == lib.length (lib.unique ids);
            message = "webApps/webAppsLocal: entry names must be unique";
          }
        ];

        hm = { osConfig, ... }:
          let
            remote = render osConfig "default" osConfig.webApps;
            local = render osConfig "lan" osConfig.webAppsLocal;
          in
          {
            home.packages = remote.commands ++ local.commands;
            xdg.desktopEntries = remote.entries // local.entries;
          };
      };
    };
}
