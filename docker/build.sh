#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo 'Missing argument: docker image name'
  exit 1
fi

if [ -z "$2" ]; then
  echo 'Missing argument: Dockerfile name'
  exit 1
fi

build_image="$1"
dockerfile="$2"
cache_dir=tmp

# Parse docker tag from image name
IFS=':' read -ra build_image_ary <<< "$1"

cache_container=''
tar_container=''

function cleanup {
  if [ -n "$cache_container" ]; then
    docker stop ${cache_container}
    docker rm -fv ${cache_container}
  fi

  if [ -n "$tar_container" ]; then
    docker rm -fv ${tar_container}
  fi

  rm -f ${cache_dir}/cidfile
}

trap cleanup EXIT

function join { local IFS="$1"; shift; echo "$*"; }

declare -a build_args
mkdir -p ${cache_dir}

if [ -f $(pwd)/${cache_dir}/build-cache.tar.gz ]; then
  docker run --name build-cache -d nginx:stable-alpine
  cache_container=build-cache
  docker cp $(pwd)/${cache_dir}/build-cache.tar.gz build-cache:/usr/share/nginx/html/build-cache.tar.gz
  build_args+=("--build-arg cache_host=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' build-cache)")
fi

build_args_str="$(join ' ' "${build_args[@]}")"
# docker build --pull -t ${build_image} -f ${dockerfile} ${build_args_str} .
docker build -t ${build_image} -f ${dockerfile} ${build_args_str} .


docker run -t --cidfile=${cache_dir}/cidfile ${build_image} bash -c docker/push-cache.sh
tar_container=$(cat ${cache_dir}/cidfile)
docker cp ${tar_container}:/tmp/build-cache.tar.gz ${cache_dir}/build-cache.tar.gz
