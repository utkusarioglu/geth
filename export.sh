source .env

if [ -z "$1"]
then
  echo "Export directory is required as the first param. Exiting"
  exit 1
fi

ACCOUNTS=$(docker exec -it geth_geth_1 sh -c "cd /$DATADIR/keystore && echo *")

echo "Coinbase pass:"
echo $COINBASE_PASS

mkdir -p $1

for account in $ACCOUNTS;
do
  docker exec -it geth_geth_1 sh -c \
    "cat /$DATADIR/keystore/$account" \
    > $1/$account.json
done;
echo "You can find the complete dump in $1"
