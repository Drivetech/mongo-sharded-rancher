FROM alpine:3.6@sha256:f006ecbb824d87947d0b51ab8488634bf69fe4094959d935c0c103f4820a417d

LABEL maintainer "Leonardo Gatica <lgatica@protonmail.com>"

ENV GIDDYUP_VERSION=0.19.0

RUN mkdir -p /opt/rancher/bin
COPY entrypoint.sh /entrypoint.sh
COPY scripts/* /opt/rancher/bin/
RUN apk add --no-cache curl && \
  mkdir -p /usr/local/etc/redis && \
  curl -sL -o /opt/rancher/bin/giddyup https://github.com/rancher/giddyup/releases/download/v${GIDDYUP_VERSION}/giddyup && \
  chmod +x /entrypoint.sh /opt/rancher/bin/*

ENTRYPOINT ["/entrypoint.sh"]
