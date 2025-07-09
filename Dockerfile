FROM alpine:latest

# install minimal NFS userland
RUN apk add --no-cache nfs-utils

# copy entrypoint and make executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
