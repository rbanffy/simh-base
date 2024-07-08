FROM debian:testing-slim

LABEL maintainer="Ricardo Bánffy <rbanffy@gmail.com>"

COPY simh-master /simh

RUN DEBIAN_FRONTEND=noninteractive \
    apt update && \
    apt -y full-upgrade && \
    # Install build requirements
    apt install -y --no-install-recommends \
    build-essential \
    cmake \
    cmake-data \
    gcc-14 \
    libedit-dev \
    libegl1-mesa-dev \
    libfreetype6-dev \
    libgles2-mesa-dev \
    libpcap-dev \
    libpcre3-dev \
    libpng-dev \
    libsdl2-dev \
    libsdl2-ttf-dev \
    libvdeplug-dev \
    pkg-config && \
    cd /simh && \
    # Build with GCC-14
    CC=gcc-14 cmake/cmake-builder.sh -f unix && \
    mv -v /simh/BIN/* /usr/local/bin && \
    # Remove the build reqirements
    apt -y purge \
    build-essential \
    cmake-data \
    gcc-14 \
    libedit-dev \
    libegl1-mesa-dev \
    libfreetype6-dev \
    libgles2-mesa-dev \
    libpcap-dev \
    libpcre3-dev \
    libpng-dev \
    libsdl2-dev \
    libsdl2-ttf-dev \
    libvdeplug-dev \
    pkg-config && \
    rm -rf /var/lib/apt/lists/* /simh
