FROM alpine:3.6@sha256:d6bfc3baf615dc9618209a8d607ba2a8103d9c8a405b3bd8741d88b4bef36478

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
