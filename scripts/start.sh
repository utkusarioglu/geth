#!/bin/sh

# Gets the account address at the given index
# @param index - index of the account to be returned
function get_account_address() {
  geth account list --datadir $DATADIR | head -n "$1" | tail -n 1 | awk -F '[{}]' '{print($2)}'
}

# Amends the genesis.json file that will be fed to the geth instance
# It prints the final genesis_edit.json file on the console as well as
# creating a genesis_edit.json file at the root.
function ammend_genesis_file() {
  EXTRA_DATA_START="0x$(printf %64s | tr " " "0")" #32 zero bytes
  EXTRA_DATA_END="$(printf %130s | tr " " "0")" # 65 zero bytes
  EXTRA_DATA="${EXTRA_DATA_START}$(get_account_address 1)${EXTRA_DATA_END}"

  ACCOUNT_ARGS=""
  for i in 1 2 3 4 5;
  do
    ACCOUNT_ARGS="$ACCOUNT_ARGS -e \"s/{{ACCOUNT_$i}}/$(get_account_address $i)/g\"";
  done;

  sh -c "sed -e \"s/{{EXTRA_DATA}}/$EXTRA_DATA/g\" \
    $ACCOUNT_ARGS \
    /genesis.json \
    > /genesis_edit.json"

  echo "Using the following genesis file:"
  cat genesis_edit.json
}

# Creates default accounts if none exists
function create_accounts() {
  echo $COINBASE_PASS > /.pw
  if [  -n "$(find /$DATADIR/keystore -prune -empty 2>/dev/null)" ]
  then
    echo "No accounts found. Creating 5 accounts..."
    for i in 1 2 3 4 5; do
      geth account new --datadir "$DATADIR" --password "/.pw"
    done;
  fi
}

# Amends genesis file with keystore accounts
# Inits geth with these accounts
function init_geth() {
  if [ ! -f /genesis_edit.json ];
  then
    echo "Ammending genesis file with runtime values..."
    ammend_genesis_file 

    echo "Initializing Geth"
    geth init "/genesis_edit.json" --datadir "$DATADIR"
  fi
}

# Starts geth with the created accounts and a bunch of
# dev-friendly settings
function start_geth() {
  echo "Starting Geth..."
  geth \
    --datadir "$DATADIR" \
    --nodiscover \
    --unlock "$(get_account_address 1)" \
    --password "/.pw" \
    --networkid 1 \
    --mine \
    --miner.etherbase "$(get_account_address 1)" \
    --miner.threads 1  \
    --allow-insecure-unlock \
    --http \
    --http.addr 0.0.0.0 \
    --http.api "db,eth,net,web3,personal,web3,debug" \
    --http.corsdomain '*' \
    --ws \
    --ws.addr 0.0.0.0 \
    --ws.api "db,eth,net,web3,personal,web3" \
    --ws.origins '*'
    # --dev \
}

create_accounts
init_geth
start_geth