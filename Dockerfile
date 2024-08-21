FROM debian:stable-slim

LABEL maintainer="Ricardo Bánffy <rbanffy@gmail.com>"

RUN DEBIAN_FRONTEND=noninteractive \
    apt update && \
    apt upgrade -y && \
    apt install -y --no-install-recommends simh && \
    apt -y autoremove && \
    rm -rf /var/lib/apt/lists/*
