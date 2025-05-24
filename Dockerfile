FROM debian:testing-slim

LABEL maintainer="Ricardo Bánffy <rbanffy@gmail.com>"

ARG QEMU_CPU

COPY simh-master /simh

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get -y full-upgrade && \
    # Install build requirements
    apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    cmake-data \
    libedit-dev \
    libegl1-mesa-dev \
    libfreetype6-dev \
    libgles2-mesa-dev \
    libpcap-dev \
    libpcre2-dev \
    libpng-dev \
    libsdl2-dev \
    libsdl2-ttf-dev \
    libvdeplug-dev \
    pkg-config && \
    cd /simh && \
    cmake/cmake-builder.sh -c Release -f unix --notest -p && \
    # Install the binaries
    mv -v /simh/BIN/* /usr/local/bin && \
    # Remove the build reqirements
    apt-get -y purge \
    build-essential \
    cmake \
    cmake-data \
    libedit-dev \
    libegl1-mesa-dev \
    libfreetype6-dev \
    libgles2-mesa-dev \
    libpcap-dev \
    libpcre2-dev \
    libpng-dev \
    libsdl2-dev \
    libsdl2-ttf-dev \
    libvdeplug-dev \
    pkg-config && \
    rm -rf /var/lib/apt/lists/* /simh && \
    echo Done!