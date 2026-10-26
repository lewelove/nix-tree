{ ... }:

{
  flake.lib.sponsorblock = { pkgs, lib, settings ? {} }: let
    version = "6.1.7";

    rev = "75a880f0b5d547baa500122a20eefe00af5f6efb";

    # Public key pinned in the built manifest, so the extension keeps one ID
    # across versions and does not lose its storage on every bump.
    manifestKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAu6pNMR0EXOyD8g9UoF4dchTTed/hIiCVZza04RgYh/aw+RwBvWmdsy61O/xQq8duv4xxPQtO5VYtH7oodM5qJjNbN7e4xIru2DLZH8tTkhDV8QfI3rysHde/GxuJZhElun5k/Cz58Fo49AX/F6ir+OloVtkuOkbvi8vP7+rpKyjJLSY9sKj4vxUxerC2pEM69z9NrGA+zMt38yBco1ZGejqp/sm+QAMPYhcVO07z0+VCOlJab7hfLAT6tB+SW824lnqg3nEdVBtIr6rmVnwbPLhZUlBOSeg5KDU3tDrcYJ3u6uTisAs7tibS/O2g9MFtUZ/WP7ldm8b98Tbv5oD4CQIDAQAB";

    # sha256 of the DER public key, first 128 bits, hex mapped 0-f to a-p
    extensionId = "iccialjkhcgnfhjeealnglajhcabhmbm";

    # Browser export, revisit with the extension's export button. Values passed
    # as `settings` win over it, e.g. { settings = { showUpsells = false; }; }
    imported = builtins.fromJSON (builtins.readFile ./config.json);

    # Not settings: identity, server-derived state, progress, device data
    undeclarableKeys = [
      "userID"
      "permissions"
      "payments"
      "isVip"
      "minutesSaved"
      "skipCount"
      "sponsorTimesContributed"
      "submissionCountSinceCategories"
      "hideDiscordLaunches"
      "donateClicked"
      "showPopupDonationCount"
      "shownDeArrowPromotion"
      "deArrowInstalled"
      "ytInfoPermissionGranted"
      "categoryPillColors"
      "downvotedSegments"
      "unsubmittedSegments"
      "skipProfileTemp"
      "navigationApiAvailable"
    ];

    managed = lib.filterAttrs (_: value: value != null)
      (removeAttrs (imported // settings) undeclarableKeys);

    # Chromium hands `chrome.storage.managed` to an extension only if its
    # manifest has storage.managed_schema, and the policy engine silently drops
    # any top-level key the schema does not declare. Chrome's schema dialect
    # rejects wildcards at the root, so derive a schema from the values.
    schemaFor = value:
      if builtins.isBool value then { type = "boolean"; }
      else if builtins.isInt value then { type = "integer"; }
      else if builtins.isFloat value then { type = "number"; }
      else if builtins.isString value then { type = "string"; }
      else if builtins.isList value then {
        type = "array";
        items = if value == [] then { type = "string"; } else schemaFor (builtins.head value);
      }
      else if builtins.isAttrs value then {
        type = "object";
        properties = builtins.mapAttrs (_: schemaFor) value;
      }
      else { type = "string"; };

    schema = {
      "$schema" = "http://json-schema.org/draft-04/schema#";
      type = "object";
      properties = builtins.mapAttrs (_: schemaFor) managed;
    };

    src = pkgs.fetchgit {
      url = "https://github.com/lewelove/SponsorBlock";
      inherit rev;
      fetchSubmodules = true;
      hash = "sha256-zTUQj5YblBSL4zcz6cIepLjL1+Yv0Y1otLCsBq8Caog=";
    };

    build = pkgs.buildNpmPackage {
      pname = "sponsorblock";
      inherit version src;

      npmDepsHash = "sha256-Bu4zFSe1UU/bp/pdfwR6379SPPOQr7FO3RWRMzeCwME=";

      # chromedriver downloads a binary at rebuild time; only selenium tests need it
      npmRebuildFlags = [ "--ignore-scripts" ];

      postPatch = ''
        cp config.json.example config.json
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        cp -r dist/. $out/

        runHook postInstall
      '';
    };

    extension = pkgs.runCommand "sponsorblock-${version}" {
      nativeBuildInputs = [ pkgs.jq ];
    } ''
      cp -r ${build}/. $out
      chmod -R u+w $out

      ${pkgs.jq}/bin/jq --arg key "${manifestKey}" \
        '. + {key: $key, storage: {managed_schema: "managed_schema.json"}}' \
        $out/manifest.json > manifest.json
      mv manifest.json $out/manifest.json

      printf '%s\n' '${builtins.toJSON schema}' > $out/managed_schema.json
    '';
  in {
    extensions.chromium = extension;

    inherit extensionId;

    policies.chromium = {
      "3rdparty".extensions.${extensionId} = managed;
    };
  };
}
