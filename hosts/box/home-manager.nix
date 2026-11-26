{ id, ... }:

{
  home-manager.users.${id.user}.home.activationGenerateGcRoot = false;
}
