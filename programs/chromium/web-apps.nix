{ self, lib, ... }:

{
  flake.nixosModules.web-apps = { config, ... }:
    let
      appType = lib.types.attrsOf (lib.types.submodule {
        options = {
          name = lib.mkOption { type = lib.types.str; };
          url = lib.mkOption { type = lib.types.str; };
          icon = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
        };
      });

      entriesFor = osConfig: instance: apps:
        let
          browser = osConfig.chromium.instances.${instance};
        in
        lib.mapAttrs' (id: app:
          lib.nameValuePair id {
            inherit (app) name icon;
            exec = "${browser.package}/bin/${browser.binary} --app=${app.url}";
            terminal = false;
          }
        ) apps;
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

        hm = { osConfig, ... }: {
          xdg.desktopEntries =
            entriesFor osConfig "default" osConfig.webApps
            // entriesFor osConfig "lan" osConfig.webAppsLocal;
        };
      };
    };
}
