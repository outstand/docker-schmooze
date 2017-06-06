#!/bin/dumb-init /bin/bash

BINARY="bundle exec schmooze"

if ${BINARY} help "$1" 2>&1 | grep -q "schmooze $1"; then
  set -- ${BINARY} "$@"
fi

exec "$@"
