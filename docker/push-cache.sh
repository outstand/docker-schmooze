#!/bin/bash
set -ex

mkdir -p /cache
cd /cache
cp -a /usr/local/bundle /cache/bundle
tar -zcf /tmp/build-cache.tar.gz .
rm -rf /cache
