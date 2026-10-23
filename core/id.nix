{ ... }:

let
  id = {
    user = "lewelove";
    email = "lewelove@proton.me";
    sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINngwDtUZAiEALEZ1XhPXX221hYqjGSaqWRnvaUnpMXT lewelove@proton.me";
    repoPath = "/home/lewelove/nix-tree";
  };
in
{
  flake.nixosModules.id = { ... }: {
    _module.args.id = id;
  };
}
