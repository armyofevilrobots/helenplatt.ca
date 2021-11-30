FROM debian:bullseye-slim

ENV HUGO_DESTINATION="public" \
    HUGO_ENV="DEV" \
    HOME="/tmp"

RUN apt update \
 && DEBIAN_FRONTEND=noninteractive apt install -y wget bash-completion tzdata make ca-certificates wget curl awscli \
 && rm -rf /var/lib/apt/lists/* \
 && find /tmp -mindepth 1 -maxdepth 1 | xargs rm -rf \
 && mkdir -p /src /target \
 && chmod a+w /src /target \
 && wget https://github.com/gohugoio/hugo/releases/download/v0.89.4/hugo_extended_0.89.4_Linux-64bit.deb \
 && dpkg -i hugo_extended_0.89.4_Linux-64bit.deb



WORKDIR /src
COPY Makefile invalidate.sh /usr/local/bin/
VOLUME /src

ENTRYPOINT ["hugo"]