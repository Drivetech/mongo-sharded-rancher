FROM alpine:3.6@sha256:d6bfc3baf615dc9618209a8d607ba2a8103d9c8a405b3bd8741d88b4bef36478

LABEL maintainer "Leonardo Gatica <lgatica@protonmail.com>"

RUN mkdir -p /opt/mongodb
COPY entrypoint.sh /entrypoint.sh
COPY scripts /opt/mongodb/scripts
RUN chmod +x /entrypoint.sh /opt/mongodb/scripts/*.sh

ENTRYPOINT ["/entrypoint.sh"]
