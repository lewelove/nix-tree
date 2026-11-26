# Builds the read-only EROFS store disk for box.
#
# This is microvm.nix's store disk builder with one change. Upstream stages the
# closure by bwrap-binding every store path into a scratch directory, and falls
# back to copying the whole closure when bwrap fails. A closure path that is a
# symlink into /home (home-manager's live dotfile links) dangles inside the
# build sandbox, so bwrap aborted on every rebuild and the fallback copied
# 2.7 GB across 206k files. Creating those links instead of binding them keeps
# them links and keeps the fallback out of the build.
#
# Delete this file and the override that uses it when upstream fixes this.
{ config, lib, pkgs }:

let
  regInfo = pkgs.closureInfo {
    rootPaths = [ config.system.build.toplevel ];
  };

  closure = pkgs.writeClosure (
    [ config.system.build.toplevel ] ++ lib.optional config.nix.enable regInfo
  );

in
pkgs.buildPackages.runCommandLocal "microvm-store-disk.erofs" {
  nativeBuildInputs = with pkgs.buildPackages; [
    bubblewrap
    erofs-utils
    time
    util-linux
  ];
} ''
  mkdir store
  args=(--dev-bind / / --chdir "$PWD")
  while read -r path; do
    dest="$PWD/store/$(basename "$path")"
    if [ -L "$path" ]; then
      ln -s "$(readlink "$path")" "$dest"
    else
      args+=(--ro-bind "$path" "$dest")
    fi
  done < <(sort -u ${closure})

  bwrap "''${args[@]}" -- time mkfs.erofs ${lib.escapeShellArgs config.microvm.storeDiskErofsFlags} \
    -T 0 --all-root -L nix-store --mount-point=/nix/store $out store

  # The guest mounts this disk by label. A wrong label means an emergency shell
  # instead of a visible error, so fail the build here.
  probe=$(blkid -p -o udev "$out")
  grep -qx 'ID_FS_TYPE=erofs' <<<"$probe" && grep -qx 'ID_FS_LABEL=nix-store' <<<"$probe" \
    || { echo "store disk label check failed: $probe" >&2; exit 1; }
''
