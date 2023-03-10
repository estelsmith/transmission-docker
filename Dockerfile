# syntax=docker/dockerfile:1

FROM registry.home.estelsmith.com/alpine:3.17

RUN apk --no-cache add tini jq gettext transmission-cli transmission-daemon
COPY entrypoint.sh /entrypoint.sh
COPY default-settings.json /default-settings.json
COPY default-slurp.json /default-slurp.json

RUN adduser -s /sbin/nologin -h /app -H -D appuser

RUN <<EOF
  chmod 0755 /entrypoint.sh
  for i in config torrents incomplete downloads; do
    mkdir -p "/app/${i}"
    chown appuser:appuser "/app/${i}"
  done
EOF

VOLUME /app/config
VOLUME /app/torrents
VOLUME /app/incomplete
VOLUME /app/downloads

EXPOSE 9091
EXPOSE 51413

USER appuser:appuser
WORKDIR /app
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
CMD []
