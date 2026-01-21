FROM ubuntu:20.04

LABEL maintainer="childrens-bti-bfx"

ARG DEBIAN_FRONTEND=noninteractive

# Install minimal build dependencies for svaba
RUN apt-get update && apt-get install -y \
    autoconf \
    automake \
    git \
    g++ \
    zlib1g-dev \
    cmake \
    libbz2-dev \
    liblzma-dev \
    wget \
    tabix \
    && rm -rf /var/lib/apt/lists/*

# Clone svaba recursively (includes all submodules)
RUN git clone --recursive https://github.com/walaj/svaba

# Checkout v1.2.0 and update submodules
RUN cd svaba && \
    git checkout v1.2.0 && \
    git submodule update --init --recursive && \
    ./autogen.sh

# Patch to restore backward-compatible --tumor-bam/--normal-bam aliases from 1.1.0
RUN cd svaba && \
    sed -i 's/"case-bam"/"tumor-bam"/; s/"control-bam"/"normal-bam"/' src/svaba/run_svaba.cpp

# Configure, build, and install svaba with parallel jobs
RUN cd svaba && \
    ./configure && \
    make -j$(nproc) && \
    make -j$(nproc) install

# Download seq_cache_populate.pl for CRAM support
RUN wget -O /usr/local/bin/seq_cache_populate.pl https://raw.githubusercontent.com/samtools/samtools/1.16/misc/seq_cache_populate.pl && \
    chmod 755 /usr/local/bin/seq_cache_populate.pl

# Add svaba binary to system PATH
ENV PATH="${PATH}:/svaba/bin"
