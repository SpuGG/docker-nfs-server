#!/bin/sh
set -x

echo "[entrypoint] Starting NFS server container..."

# 1. Create anonymous user and group matching host's PUID/PGID
addgroup -g "${PGID}" nfsnogroup 2>/dev/null || true
adduser -u "${PUID}" -G nfsnogroup -D nfsnobody 2>/dev/null || true

# Ensure correct ownership of exports directory
# (For now, I expect the host to configure PGID/PUID to the same values as the ones owned by /exports)
# chown -R nfsnobody:nfsnogroup /exports

# 2. Create idmapd.conf for NFSv4 user mapping
echo "[entrypoint] Configuring /etc/idmapd.conf..."
cat > /etc/idmapd.conf <<EOF
[General]
Domain = ${NFS_DOMAIN}

[Mapping]
Nobody-User = nobody
Nobody-Group = nogroup
EOF

# 3. Create /etc/exports only if not bind-mounted
if [ ! -f /etc/exports ]; then
  echo "[entrypoint] Generating default /etc/exports..."
  cat > /etc/exports <<EOF
# Default export for NFS container
# All clients will be squashed to anon UID/GID = ${PUID}/${PGID}
/exports *(rw,sync,no_subtree_check,all_squash,anonuid=${PUID},anongid=${PGID},fsid=0)
EOF
else
  echo "[entrypoint] Using bind-mounted /etc/exports file—skipping generation."
  echo ---
  cat /etc/exports
  echo ---
fi

# 4. Start required NFS daemons
echo "[entrypoint] Starting NFS daemons..."
rpcbind -w
rpc.statd --no-notify
rpc.idmapd
mountd --no-nfs-version 1   # v3 and v4 only
exec rpc.nfsd

# 5. Apply exports configuration
exportfs -r

# 6. Tail to keep container alive
echo "[entrypoint] NFS server running. Waiting for requests..."
tail -f /dev/null
echo "[entrypoint] This is after the tail line..."

# Just in case tail fails...
sleep infinity
echo "[entrypoint] It was sleeping before this and should never hit this line..."
