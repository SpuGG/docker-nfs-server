# docker-nfs-server

A lightweight docker setup for enabling NFS on the host (via network mode: host). Targeted for portainer consumption.

My original use case for a LibreElec 11.x series box (Kodi) to expose some NFS shares to see if things are faster.

The primary consumers will be other Kodi clients (of varying versions), so it needs to support NFS v3 (and I plan to enable NFS v4 as well).

My hope is to configure once, trouble shoot and forget how I ever did it (until a decade later when I might need to do it all over again).