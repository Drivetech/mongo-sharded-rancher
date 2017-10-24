FROM alpine:3.6@sha256:f006ecbb824d87947d0b51ab8488634bf69fe4094959d935c0c103f4820a417d

LABEL maintainer "Leonardo Gatica <lgatica@protonmail.com>"

RUN mkdir -p /opt/mongodb
COPY entrypoint.sh /entrypoint.sh
COPY scripts /opt/mongodb/scripts
RUN chmod +x /entrypoint.sh /opt/mongodb/scripts/*.sh

ENTRYPOINT ["/entrypoint.sh"]
