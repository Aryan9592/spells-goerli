#!/usr/bin/env bash
set -e

[[ "$ETH_RPC_URL" ]] || { echo "Please set a ETH_RPC_URL"; exit 1; }

[[ "$1" =~ 0x* ]] || { echo "Please specify the transaction to inspect (e.g. tx=0x<txhash>)"; exit 1; }

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)

    case "$KEY" in
            tx)      TXHASH="$VALUE" ;;
            *)       TXHASH="$KEY"
    esac
done

SOURCE="src/test/config.sol"
KEY_TIMESTAMP="deployed_spell_created"
KEY_BLOCK="deployed_spell_block"

timestamp=$(cast block "$(cast tx "${TXHASH}"|grep blockNumber|awk '{print $2}')"|grep timestamp|awk '{print $2}')
block=$(cast tx "${TXHASH}"|grep blockNumber|awk '{print $2}')

sed -i "s/\($KEY_TIMESTAMP *: *\)[0-9]\+/\1$timestamp/g" "$SOURCE"
sed -i "s/\($KEY_BLOCK *: *\)[0-9]\+/\1$block/g" "$SOURCE"

echo -e "Network: $(cast chain)"
echo "config.sol updated with deployed timestamp and block"
