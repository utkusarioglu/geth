#!/bin/sh
source .env

if [ -z "$1" ]
then
  echo "Export directory is required as the first param. Exiting"
  exit 1
fi

# Runs the commands in docker or on the current machine
# depending on the presence of docker
function dockerize_command() {
  COMMAND=$1
  if command -v docker &> /dev/null
  then
    echo "$(docker exec -it geth-geth-1 sh -c "$COMMAND")"
  else
    echo "$(sh -c "$COMMAND")"
  fi
}

# Dumps accounts to the argument 1 path
# @params path to dump to
function dump_accounts() {
  DUMP_PATH=$1
  mkdir -p $DUMP_PATH
  for ACCOUNT in $(dockerize_command "cd /$DATADIR/keystore && echo *");
  do
    PROPS=$(dockerize_command "cat /$DATADIR/keystore/$ACCOUNT") 
    echo $PROPS > $DUMP_PATH/$ACCOUNT.json
  done;
  echo "You can find the complete dump at: $DUMP_PATH"
}

dump_accounts $1
