#!/bin/sh

docker compose -f ${0%/*}/../docker-compose.dev.yml up -d

cat <<EOF
Started 2 chains:

chain1
  http port: 8545
  ws port: 8546
  chain id: 8545

chain 2
  http port: 9545
  ws port: 9546
  chain id: 9545
EOF
