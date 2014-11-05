#!/bin/env bash

FROM=$1
TAG=$2

mkdir -p tmp/docker_build/

cat > tmp/docker_build/Dockerfile <<EOI
FROM $FROM

ADD dowse.tar.bz2 /usr/local/src/dowse
WORKDIR /usr/local/src/dowse
RUN export DEBIAN_FRONTEND=noninteractive ; \
    apt-get update && \
    apt-get install -y zsh && \
    zsh utils/debian_install.sh && \
    apt-get clean

EOI

tar cjf tmp/docker_build/dowse.tar.bz2 . --exclude .git --exclude tmp

docker build -t $TAG tmp/docker_build/
