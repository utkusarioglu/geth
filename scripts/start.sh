#!/bin/sh

if [ ! -f "/.pw" ]; then 
  echo $COINBASE_PASS > /.pw
  geth account new --datadir "$DATADIR" --password "/.pw" > /log
  # OWNER_ACCOUNT=$(geth account list --datadir $DATADIR | head -n 1 | awk -F '[{}]' '{print($2)}')
  
  geth init "/genesis.json" --datadir "$DATADIR"
fi

geth makedag 0 ~/.ethash

# You need this to be able to connect to geth from outside docker.
# Read more about securing geth. Because this setup wildly insecure
# https://medium.com/coinmonks/securing-your-ethereum-nodes-from-hackers-8b7d5bac8986
geth \
  --datadir "$DATADIR" \
  --nodiscover \
  --unlock "$(geth account list | head -n 1)" \
  --password "/.pw" \
  --mine \
  --miner.threads 1 \
  --http \
  --http.addr 0.0.0.0 \
  --rpc \
  --rpcaddr 0.0.0.0 \
  --ws \
  --ws.addr 0.0.0.0