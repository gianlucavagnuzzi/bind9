
## https://hub.docker.com/_/debian/tags
FROM debian:13.4-slim

## https://packages.debian.org/search?keywords=bind9
ENV bind9V="bind9=1:9.20.18-1~deb13u1"

LABEL org.opencontainers.image.authors="rardcode <vagnu00#gmx.com>"
LABEL Description="Bind9 server based on Debian."

ARG DEBIAN_FRONTEND=noninteractive

RUN set -xe && \
  : "---------- ESSENTIAL packages INSTALLATION ----------" \
  && apt-get -q -y update \
  && apt-get -q -y -o "DPkg::Options::=--force-confold" -o "DPkg::Options::=--force-confdef" install \
     apt-utils \
     rsync \
     procps \
  && apt-get -q -y autoremove \
  && apt-get -q -y clean \
  && rm -rf /var/lib/apt/lists/*

RUN set -xe && \
  : "---------- SPECIFIC packages INSTALLATION ----------" \
  && apt-get -q -y update \
  && apt-get -q -y -o "DPkg::Options::=--force-confold" -o "DPkg::Options::=--force-confdef" install \
     $bind9V \
  && apt-get -q -y autoremove \
  && apt-get -q -y clean \
  && rm -rf /var/lib/apt/lists/*

ADD rootfs /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/named", "-u", "bind", "-g", "-c", "/data/named.conf"]
