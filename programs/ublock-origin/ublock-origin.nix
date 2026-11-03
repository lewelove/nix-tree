{ ... }:

{
  flake.lib.ublockOrigin = { pkgs, lib, settings ? import ./_settings.nix }: let
    version = "1.75.0";

    extensionPath = "share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}";

    inherit (settings) filterLists adminSettings;

    userFilters =
      if builtins.isList settings.userFilters then
        settings.userFilters
      else
        lib.filter (line: line != "") (lib.splitString "\n" settings.userFilters);

    managedSettings = {
      adminSettings = builtins.toJSON adminSettings;
      toOverwrite = {
        filters = userFilters;
        inherit filterLists;
      };
    };

    zenExtension = pkgs.stdenvNoCC.mkDerivation {
      pname = "ublock-origin";
      inherit version;

      src = pkgs.fetchurl {
        url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.firefox.signed.xpi";
        hash = "sha256-W3RBWGBFY3BkS9gPFhJehlsObDVrtd/PuEBpln6qUoc=";
      };

      dontUnpack = true;

      installPhase = ''
        install -Dm644 "$src" $out/${extensionPath}/uBlock0@raymondhill.net.xpi
      '';

      passthru.addonId = "uBlock0@raymondhill.net";
    };

    zenPolicy = {
      ExtensionSettings."uBlock0@raymondhill.net" = {
        installation_mode = "force_installed";
        install_url = "file://${zenExtension}/${extensionPath}/uBlock0@raymondhill.net.xpi";
      };

      "3rdparty".Extensions."uBlock0@raymondhill.net" = managedSettings;
    };
  in {
    extensions.zen = zenExtension;
    policies.zen = zenPolicy;
  };
}
