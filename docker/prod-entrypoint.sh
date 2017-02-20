#!/bin/dumb-init /bin/bash
set -x

consul_service() {
  declare name="$1"
  curl --fail -Ss ${CONSUL_HOST}:8500/v1/catalog/service/${name}
}

CONSUL_SERVICE_ADDRESS_KEY='.Address'
if [ -n "$CONSUL_USE_SERVICE_ADDRESS" ]; then
  CONSUL_SERVICE_ADDRESS_KEY='.ServiceAddress'
fi

consul_service_host() {
  declare name="$1"
  consul_service ${name} \
    | jq -r ".[0] | ${CONSUL_SERVICE_ADDRESS_KEY}"
}

consul_service_port() {
  declare name="$1"
  consul_service ${name} \
    | jq -r '.[0] | .ServicePort | tostring'
}

consul_service_host_port() {
  declare name="$1"
  consul_service ${name} \
    | jq -r ".[0] | [${CONSUL_SERVICE_ADDRESS_KEY},(.ServicePort | tostring)] | join(\":\")"
}

if [ "$(stat -c %u /usr/local/bundle)" = '0' ]; then
  chown deploy:deploy /usr/local/bundle
fi

if [ "$1" = 'bundle' ]; then
  set -- gosu deploy "$@"
elif ls /usr/local/bundle/bin | grep -q "\b$1\b"; then
  set -- gosu deploy bundle exec "$@"

  if [ -z "$CONSUL_HOST" ]; then
    echo 'Unable to find CONSUL_HOST in environment!'
    exit 1
  fi

  set -e
  fsconsul -addr ${CONSUL_HOST}:8500 -once howmoneyworks-api/config /srv/config/
fi

exec "$@"
