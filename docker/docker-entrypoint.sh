#!/bin/dumb-init /bin/bash

# BINARY="gosu schmooze bundle exec schmooze"
BINARY="bundle exec schmooze"

# if [ "$1" = 'bundle' ]; then
#   set -- gosu schmooze "$@"
if ${BINARY} help "$1" 2>&1 | grep -q "schmooze $1"; then
  set -- ${BINARY} "$@"
fi

exec "$@"
