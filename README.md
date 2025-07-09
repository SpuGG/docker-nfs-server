# docker-nfs-server

A lightweight docker setup for enabling NFS on the host (via network mode: host). Targeted for portainer consumption.

**Note: This doesn't work on LibreElec 11.x.**

My original use case for a LibreElec 11.x series box (Kodi) to expose some NFS shares to see if things are faster.

The primary consumers will be other Kodi clients (of varying versions), so it needs to support NFS v3 (and I plan to enable NFS v4 as well).

My hope is to configure once, trouble shoot and forget how I ever did it (until a decade later when I might need to do it all over again).

I have a portainer deployment to make things slightly easier for my LibreElec instance, but with a portainer setup, this line in the docker-compose.yml doesn't work.
```
- ${EXPORTS_CONF:-./etc-exports}:/etc/exports:ro
```
Because portainer has it's own /data volume where it creates /data/compose/<id>/ to dump all the files. the etc-exports does indeed go there, but when you specify `./etc-exports`, the '`.`' gets translated to `/data/compose/<id>/` (e.g. id = 3, so `/data/compose/3`) which it then tries to find on the host system. Basically `etc-exports` disappears after it's composed so it's no longer around (and not on the host) to get volume bound. So, one workaround is just to copy it, but then someone would need to either fork the repo or whatever to make changes to `etc-exports` which I find stupid.

> In case your Docker-fu is low, that line just means `EXPORTS_CONF` will take on `./etc-exports` unless someone overrides it in the environment variable as something else.

Despite copying `etc-exports` to the host somewhere and pointing `EXPORTS_CONF` environment variable to it, the container kept restarting (but at least deployed successfully). I'm still not exactly sure what's causing the restarts.

## Alternative Test

Since it wasn't really working, I thought I'd try another server I found online.

https://hub.docker.com/r/erichough/nfs-server/

However, this one failed to start because it needs `port 111`, which LibreElec has bound to `systemd`.

So at least for NFSv3, this is a non-starter (e.g. perhaps if enough time is spent on it, but WRT to ROI for time, this is the end of this particular exercise).

## Ideas to Explore

- Rsync the files regularly to another host and server the NFS up there
- NFS on another host (e.g. VM) but samba mount the LibreElec instance over ethernet.

In particular it was my wireless Kodi clients that were extremely slow, so even the NFS -> Samba setup might not be terrible as the Samba part will happen over Ethernet.

A project for another day.
