# AGENTS.md

## Keep settings next to the code that needs them

A setting that exists only because some code needs it lives in the same module
as that code. Do not park it in a host-wide file.

- Networking: a firewall port, a trusted interface or a route that exists for
  one service belongs with that service.
- Environment variables: a variable that makes one driver or one program work
  belongs with that driver or program.
- Secrets: a `sops.templates` entry belongs with the code that reads the file
  it writes.

Why: a setting far from its user is a setting nobody remembers to delete. The
reader also cannot see why a port is open or why a variable exists without
searching the whole tree.

Example, the rule applied:

```nix
# programs/sing-box/sing-box.nix
{
  services.sing-box = { enable = true; settings = { /* ... */ }; };

  # The tun0 interface and the policy rules are sing-box's, so its systemd
  # glue is here too, not in the host's system.nix.
  systemd.services.sing-box.after = [ "systemd-networkd.service" ];
}
```

Host files keep what is true for the whole host: hardware, the kernel,
networkmanager, users, packages. Everything else travels with its code.
