#!/usr/bin/env bash
# Minimal "container": chroot + namespaces + cgroup v2 limits.
# Run inside the Lima VM: sudo ./scripts/mini-container.sh [rootfs]
set -euo pipefail

ROOTFS="${1:-/lab/rootfs}"
CG=/sys/fs/cgroup/mini

# "file=value" pairs written into the cgroup directory
LIMITS=(
  "memory.max=50M"
  "memory.swap.max=0"
  "cpu.max=20000 100000"
  "pids.max=50"
)

if [[ $EUID -ne 0 ]]; then
  echo "run with sudo" >&2
  exit 1
fi

if [[ ! -x "$ROOTFS/bin/sh" ]]; then
  echo "no rootfs at $ROOTFS" >&2
  exit 1
fi

# Remove the group on any exit; rmdir works only once the group is empty
cleanup() {
  rmdir "$CG" 2>/dev/null || true
}
trap cleanup EXIT

mkdir -p "$CG"
echo "+memory +cpu +pids" > /sys/fs/cgroup/cgroup.subtree_control
for kv in "${LIMITS[@]}"; do
  echo "${kv#*=}" > "$CG/${kv%%=*}"
done

# Device nodes the kernel would not create for us (Docker does this itself)
[[ -e "$ROOTFS/dev/null" ]] || mknod "$ROOTFS/dev/null" c 1 3
[[ -e "$ROOTFS/dev/zero" ]] || mknod "$ROOTFS/dev/zero" c 1 5

# Subshell: move only the child into the cgroup, so this script stays outside
# and the group is empty (removable) once the container exits
(
  echo "$BASHPID" > "$CG/cgroup.procs"
  exec unshare --fork --pid --mount --uts --ipc --net \
    chroot "$ROOTFS" /bin/sh -c 'mount -t proc proc /proc && hostname mini && exec /bin/sh'
)