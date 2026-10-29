{
  config,
  lib,
  options,
  ...
}:
let
  cfg = config.chromium;
in
{
  imports = [ ./_options.nix ];

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          let
            dirs = lib.filter (dir: dir != null) (lib.catAttrs "profileDir" (lib.attrValues cfg.instances));
          in
          lib.length dirs == lib.length (lib.unique dirs);
        message = "chromium.instances: profileDir values must be unique";
      }
    ];

    environment.etc = lib.mapAttrs' (
      name: policy:
      lib.nameValuePair "chromium/policies/managed/${name}.json" {
        text = builtins.toJSON policy;
      }
    ) cfg.policies;

    home-manager.sharedModules = lib.mkIf (options ? home-manager) [ ./_home.nix ];
  };
}
