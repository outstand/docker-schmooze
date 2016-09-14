#!/bin/sh

bridge_name=$1
shift

echo "Preparing to converse on ${bridge_name}..."

test_docker() {
  socat - UNIX-CONNECT:/var/run/docker.sock >/dev/null <<EOF
GET /info HTTP/1.1
EOF
}

until ( test_docker )
do
  echo -n '.'
  sleep 1
done

echo 'Docker is up.'

echo 'Creating network...'

allow_bridge() {
  bridge_name=$1
  echo "Allowing communication to/from ${bridge_name}"

  iptables -C FORWARD -i ${bridge_name} -j ACCEPT 2> /dev/null && \
  iptables -D FORWARD -i ${bridge_name} -j ACCEPT
  iptables -I FORWARD -i ${bridge_name} -j ACCEPT

  iptables -C FORWARD -o ${bridge_name} -j ACCEPT 2> /dev/null && \
  iptables -D FORWARD -o ${bridge_name} -j ACCEPT
  iptables -I FORWARD -o ${bridge_name} -j ACCEPT

  echo 'Done.'
}

output=$(http --check-status --ignore-stdin --timeout=120 POST http+unix://%2Fvar%2Frun%2Fdocker.sock/networks/create "$@")
status=$?

if [ "${status}" = "5" ]; then
  if echo "${output}" | egrep 'network with name .+ already exists'; then
    allow_bridge ${bridge_name}
    exit 0
  else
    echo ${output}
    exit 1
  fi
fi

if [ "${status}" != "0" ]; then
  echo ${output}
  exit 1
fi

echo ${output}

allow_bridge ${bridge_name}
