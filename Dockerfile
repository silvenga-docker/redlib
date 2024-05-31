FROM rust:1-bookworm AS builder

ARG TARGET=x86_64-unknown-linux-musl

WORKDIR /source

RUN set -xe \
    && apt-get update \
    && apt-get install -y \
    git \
    musl-tools \
    && rustup target add ${TARGET}

RUN set -xe \
    && git clone https://github.com/redlib-org/redlib . \
    && RUSTFLAGS='-C target-feature=+crt-static' cargo build --release --target ${TARGET} \
    && mkdir /app \
    && mv target/${TARGET}/release/redlib /app/redlib \
    && chmod +x /app/redlib

FROM ubuntu:noble AS final

LABEL org.opencontainers.image.authors "Mark Lopez <m@silvenga.com>"

RUN set -xe \
    && apt-get update \
    && apt-get dist-upgrade -y \
    # Common
    && apt-get install -y \
    wget \
    # Cleanup
    && apt-get autoremove -y --purge \
    && apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

COPY --from=builder /app/redlib /usr/bin/redlib

# Default user in Ubuntu Noble.
USER 1000

HEALTHCHECK --interval=1m --timeout=3s CMD wget --spider --q http://localhost:8080/settings || exit 1

EXPOSE 8080
VOLUME [ "/config" ]
ENTRYPOINT ["redlib"]
