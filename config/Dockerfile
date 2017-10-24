FROM alpine:3.6

LABEL maintainer "Leonardo Gatica <lgatica@protonmail.com>"

RUN mkdir -p /opt/mongodb
COPY entrypoint.sh /entrypoint.sh
COPY scripts /opt/mongodb/scripts
RUN chmod +x /entrypoint.sh /opt/mongodb/scripts/*.sh

ENTRYPOINT ["/entrypoint.sh"]
