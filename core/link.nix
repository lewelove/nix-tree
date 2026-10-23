{ self, ... }:

{
  flake.nixosModules.link = { config, lib, id, ... }: let
    flakeRoot = toString self;

    resolveLivePath = src:
      if builtins.isPath src then
        let
          relPath = lib.removePrefix flakeRoot (toString src);
        in
          "${id.repoPath}${relPath}"
      else if lib.hasPrefix "/" src then
        src
      else
        "${id.repoPath}/${src}";
  in {
    options.link = lib.mkOption {
      type = lib.types.attrsOf (lib.types.either lib.types.path lib.types.str);
      default = {};
      description = "Map of home-relative destinations to module-relative source paths";
    };

    config = {
      home-manager.users.${id.user}.home.file =
        lib.mapAttrs' (destination: sourcePath:
          lib.nameValuePair destination {
            source = config.home-manager.users.${id.user}.lib.file.mkOutOfStoreSymlink (resolveLivePath sourcePath);
          }
        ) config.link;
    };
  };
}
