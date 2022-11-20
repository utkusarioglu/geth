#!/bin/sh

docker compose -f ${0%/*}/../docker-compose.dev.yml up chain1 -d

cat <<EOF
Started 1 chain
  http port: 8545
  ws port: 8546
  chain id: 8545
EOF
