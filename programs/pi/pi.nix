{ ... }:

{
  flake.nixosModules.pi = { pkgs, dotfiles, ... }: {
    environment.systemPackages = [ pkgs.pi-coding-agent ];

    # Only config is linked. auth.json, models-store.json, trust.json and
    # sessions/ stay as real files in the home directory, per machine.
    hm.file = {
      ".pi/agent/AGENTS.md" = dotfiles.link ".pi/agent/AGENTS.md";
      ".pi/agent/settings.json" = dotfiles.link ".pi/agent/settings.json";
      ".pi/agent/agents" = dotfiles.link ".pi/agent/agents";
      ".pi/agent/skills" = dotfiles.link ".pi/agent/skills";
      ".pi/agent/extensions" = dotfiles.link ".pi/agent/extensions";
    };
  };
}

