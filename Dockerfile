FROM debian:stable-slim

LABEL maintainer="Ricardo Bánffy <rbanffy@gmail.com>"

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get -y full-upgrade && \
    apt-get install -y --no-install-recommends simh && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*
