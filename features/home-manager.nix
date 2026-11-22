{ inputs, lib, ... }:

{
  flake.nixosModules.home-manager = { id, config, ... }:
    let
      fileModule = { config, ... }: {
        options.file = lib.mkOption {
          type = lib.types.attrsOf lib.types.path;
          default = {};
        };

        config.home.file = lib.mapAttrs' (destination: source:
          lib.nameValuePair destination { inherit source; }
        ) config.file;
      };
    in
    {
      imports = [ inputs.home-manager.nixosModules.default ];

      options.hm = lib.mkOption {
        type = lib.types.deferredModule;
        default = {};
      };

      config = {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";
          extraSpecialArgs = { inherit inputs id; };
          users.${id.user} = {
            home.stateVersion = "26.05";
            imports = [ config.hm fileModule ];
          };
        };
      };
    };
}
