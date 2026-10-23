{ self, lib, ... }:

{
  flake.nixosModules.web-apps = { config, ... }: {
    imports = [ self.nixosModules.chromium ];

    options.webApps = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          name = lib.mkOption { type = lib.types.str; };
          url = lib.mkOption { type = lib.types.str; };
          icon = lib.mkOption { type = lib.types.str; };
        };
      });
      default = {};
    };

    config.hm = { osConfig, ... }: {
      xdg.desktopEntries = lib.mapAttrs' (id: app:
        lib.nameValuePair app.name {
          inherit (app) name icon;
          exec = "${osConfig.chromium}/bin/chromium-browser --app=${app.url}";
          terminal = false;
        }
      ) osConfig.webApps;
    };
  };
}
