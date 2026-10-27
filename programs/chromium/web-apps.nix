{ self, lib, ... }:

{
  flake.nixosModules.web-apps = { config, ... }: {
    imports = [ self.nixosModules.chromium ];

    options.webApps = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          name = lib.mkOption { type = lib.types.str; };
          url = lib.mkOption { type = lib.types.str; };
          icon = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
        };
      });
      default = {};
    };

    config.hm = { osConfig, ... }: {
      xdg.desktopEntries = lib.mapAttrs' (id: app:
        lib.nameValuePair id {
          inherit (app) name icon;
          exec = "${osConfig.chromium.instances.default.package}/bin/chromium --app=${app.url}";
          terminal = false;
        }
      ) osConfig.webApps;
    };
  };
}
