#!/bin/bash
set -x

if [ -z "$1" ]; then
  echo 'Missing argument: build cache host'
  exit 0
fi

wget -nv -T 2 -O /tmp/build-cache.tar.gz http://${1}/build-cache.tar.gz
if [ $? -ne 0 ]; then
  echo 'Unable to fetch build cache.'
else
  mkdir -p /cache && \
  cd /cache && \
    tar -zxf /tmp/build-cache.tar.gz && \
    rm /tmp/build-cache.tar.gz
  cd /usr/local/bundle && \
    mv /cache/bundle/* . && \
  rm -rf /cache
fi
