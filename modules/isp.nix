{ ... }:

{
  flake.nixosModules.isp = { pkgs, id, ... }:
    let
      user = id.user;

      isp-runner = pkgs.writeShellScriptBin "isp-runner" ''
        if [ $# -eq 0 ]; then
          exec ${pkgs.iproute2}/bin/ip netns exec isp ${pkgs.util-linux}/bin/setpriv --reuid=${user} --regid=users --init-groups ${pkgs.fish}/bin/fish
        fi
        exec ${pkgs.iproute2}/bin/ip netns exec isp ${pkgs.util-linux}/bin/setpriv --reuid=${user} --regid=users --init-groups "$@"
      '';

      isp = pkgs.writeShellScriptBin "isp" ''
        exec sudo -E ${isp-runner}/bin/isp-runner "$@"
      '';
    in
    {
      systemd.services.netns-isp = {
        description = "Isolated ISP Network Namespace";
        after = [ "network.target" "sys-subsystem-net-devices-enp3s0.device" ];
        bindsTo = [ "sys-subsystem-net-devices-enp3s0.device" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };

        script = ''
          ${pkgs.iproute2}/bin/ip netns add isp 2>/dev/null || true
          ${pkgs.iproute2}/bin/ip link add isp0 link enp3s0 type macvlan mode bridge 2>/dev/null || true
          ${pkgs.iproute2}/bin/ip link set isp0 netns isp
          ${pkgs.iproute2}/bin/ip -n isp link set lo up
          ${pkgs.iproute2}/bin/ip -n isp link set isp0 up
          ${pkgs.iproute2}/bin/ip -n isp addr add 192.168.1.50/24 brd + dev isp0 2>/dev/null || true
          ${pkgs.iproute2}/bin/ip -n isp route add default via 192.168.1.1 dev isp0 2>/dev/null || true

          mkdir -p /etc/netns/isp
          echo "nameserver 1.1.1.1" > /etc/netns/isp/resolv.conf
          echo "nameserver 9.9.9.9" >> /etc/netns/isp/resolv.conf
        '';

        postStop = ''
          ${pkgs.iproute2}/bin/ip -n isp link delete isp0 2>/dev/null || true
          ${pkgs.iproute2}/bin/ip netns delete isp 2>/dev/null || true
          rm -rf /etc/netns/isp
        '';
      };

      security.sudo.extraRules = [
        {
          users = [ user ];
          commands = [
            {
              command = "${isp-runner}/bin/isp-runner";
              options = [ "NOPASSWD" "SETENV" ];
            }
          ];
        }
      ];

      environment.systemPackages = [
        isp
        isp-runner
      ];
    };
}
