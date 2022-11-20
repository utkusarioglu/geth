#!/bin/sh

docker compose -f ${0%/*}/../docker-compose.dev.yml stop 
