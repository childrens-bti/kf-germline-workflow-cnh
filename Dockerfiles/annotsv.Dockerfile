FROM ubuntu:22.04

LABEL maintainer="childrens-bti-bfx"
LABEL version="3.5.3"
LABEL description="AnnotSV - Annotation and ranking of Structural Variations"

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    tcl \
    tcllib \
    wget \
    gzip \
    pigz \
    tar \
    bedtools \
    bcftools \
    git \
    make \
    g++ \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Download and install AnnotSV 3.5.3
WORKDIR /opt
RUN wget https://github.com/lgmgeo/AnnotSV/archive/refs/tags/v3.5.3.tar.gz && \
    tar -xzf v3.5.3.tar.gz && \
    rm v3.5.3.tar.gz && \
    cd AnnotSV-3.5.3 && \
    make PREFIX=/usr/local install && \
    cd .. && \
    rm -rf AnnotSV-3.5.3

# Set environment variables
ENV ANNOTSV=/usr/local/share/AnnotSV
ENV PATH=/usr/local/bin:$PATH

# Set working directory
WORKDIR /data

# Default command
CMD ["AnnotSV"]
