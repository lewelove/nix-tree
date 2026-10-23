{ inputs, ... }:

{
  flake.nixosModules.secrets = { config, pkgs, lib, ... }: {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    environment.systemPackages = with pkgs; [
      sops
      ssh-to-age
    ];

    sops = {
      defaultSopsFile = ./secrets.yaml;
      defaultSopsFormat = "yaml";

      age.sshKeyPaths = lib.mkDefault [
        "/etc/ssh/ssh_host_ed25519_key"
      ];

      secrets."github-token" = { };

      templates."nix-access-tokens.conf" = {
        mode = "0444";
        content = ''
          access-tokens = github.com=${config.sops.placeholder."github-token"}
        '';
      };
    };

    nix.extraOptions = ''
      !include ${config.sops.templates."nix-access-tokens.conf".path}
    '';
  };
}
