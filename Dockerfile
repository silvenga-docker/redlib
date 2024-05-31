FROM ubuntu:noble AS base

LABEL org.opencontainers.image.authors "Mark Lopez <m@silvenga.com>"

RUN set -xe \
    && apt-get update \
    && apt-get dist-upgrade -y \
    # Common
    && apt-get install -y \
    wget \
    # Redlib
    && wget https://github.com/redlib-org/redlib/releases/latest/download/redlib -O /tmp/redlib \
    && wget https://github.com/redlib-org/redlib/releases/latest/download/redlib.sha512  -O /tmp/redlib.sha512 \
    && sed -i -e 's/target\/x86_64-unknown-linux-musl\/release/\/tmp/g' /tmp/redlib.sha512 \
    && sha512sum --check /tmp/redlib.sha512 \
    && mv /tmp/redlib /usr/bin/redlib \
    && chmod +x /usr/bin/redlib \
    && rm /tmp/redlib.sha512 \
    # Cleanup
    && apt-get autoremove -y --purge \
    && apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

# Default user in Ubuntu Noble.
USER 1000

HEALTHCHECK --interval=1m --timeout=3s CMD wget --spider --q http://localhost:8080/settings || exit 1

EXPOSE 8080
VOLUME [ "/config" ]
ENTRYPOINT ["redlib"]
