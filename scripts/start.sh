#!/bin/sh

function get_owner_account() {
  geth account list --datadir $DATADIR | head -n 1 | awk -F '[{}]' '{print($2)}'
}

function edit_genesis_file() {
  OWNER_ACCOUNT=$1
  EXTRA_DATA_START="0x$(printf %64s | tr " " "0")" #32 zero bytes
  EXTRA_DATA_END="$(printf %130s | tr " " "0")" # 65 zero bytes
  EXTRA_DATA="${EXTRA_DATA_START}${OWNER_ACCOUNT}${EXTRA_DATA_END}"

  sed -e "s/{{EXTRA_DATA}}/$EXTRA_DATA/g" \
      -e "s/{{OWNER_ACCOUNT}}/$OWNER_ACCOUNT/g" \
      '/genesis.json' \
      > /genesis_edit.json  

  echo "Using the following genesis file:"
  cat genesis_edit.json
}

if [ ! -f "/.pw" ]; then 
  echo $COINBASE_PASS > /.pw
  geth account new --datadir "$DATADIR" --password "/.pw" > /log
  OWNER_ACCOUNT=$(get_owner_account)
  edit_genesis_file $OWNER_ACCOUNT

  geth init "/genesis_edit.json" --datadir "$DATADIR"
else 
  OWNER_ACCOUNT=$(get_owner_account)
fi

# You need this to be able to connect to geth from outside docker.
# Read more about securing geth. Because this setup wildly insecure
# https://medium.com/coinmonks/securing-your-ethereum-nodes-from-hackers-8b7d5bac8986
geth \
  --datadir "$DATADIR" \
  --nodiscover \
  --unlock "$OWNER_ACCOUNT" \
  --password "/.pw" \
  --networkid 1 \
  --mine \
  --miner.threads 1  \
  --allow-insecure-unlock \
  --rpc \
  --rpcaddr 0.0.0.0 \
  --http \
  --http.addr 0.0.0.0 \
  --ws \
  --ws.addr 0.0.0.0