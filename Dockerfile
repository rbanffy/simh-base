FROM debian:testing-slim

LABEL maintainer="Ricardo Bánffy <rbanffy@gmail.com>"

COPY simh-master /simh

RUN DEBIAN_FRONTEND=noninteractive \
    apt update && \
    apt upgrade -y && \
    apt install -y --no-install-recommends build-essential cmake && \
    cd /simh && \
    sh .travis/deps.sh linux && \
    cmake/cmake-builder.sh -f unix && \
    cp -v BIN/* /usr/local/bin && \
    apt purge build-essential && \
    apt -y autoremove && \
    rm -rf /var/lib/apt/lists/* /simh
