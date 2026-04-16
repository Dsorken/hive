#!/bin/bash

set -euo pipefail

NODE_ID="${HIVE_NODE_ID:-lantern_0}"
ASSET_ROOT="/tmp/lantern-runtime"
DEVNET_LABEL="${HIVE_LEAN_DEVNET_LABEL:-devnet3}"
NETWORK_LABEL="${HIVE_NETWORK:-$DEVNET_LABEL}"

case "$NETWORK_LABEL" in
    devnet3)
        DEFAULT_LANTERN_ROOT="/opt/lantern-devnet3"
        ;;
    devnet4)
        DEFAULT_LANTERN_ROOT="/opt/lantern-devnet4"
        ;;
    *)
        echo "Unsupported Lean devnet label: $NETWORK_LABEL" >&2
        exit 1
        ;;
esac

LANTERN_ROOT="${LANTERN_ROOT:-$DEFAULT_LANTERN_ROOT}"
LANTERN_BIN="${LANTERN_BIN:-$LANTERN_ROOT/bin/lantern}"

cleanup() {
    if [ -d "$ASSET_ROOT" ]; then
        rm -rf "$ASSET_ROOT"
    fi
}

trap cleanup EXIT

if [ ! -f "$ASSET_ROOT/config.yaml" ]; then
    echo "Missing prepared Lean runtime assets at $ASSET_ROOT" >&2
    exit 1
fi

FLAGS=(
    --data-dir /data
    --genesis-config "$ASSET_ROOT/config.yaml"
    --validator-registry-path "$ASSET_ROOT/validators.yaml"
    --nodes-path "$ASSET_ROOT/nodes.yaml"
    --validator-config "$ASSET_ROOT/validator-config.yaml"
    --node-id "$NODE_ID"
    --node-key-path "$ASSET_ROOT/node.key"
    --listen-address "/ip4/0.0.0.0/udp/9000/quic-v1"
    --http-port 5052
    --metrics-port 8080
    --hash-sig-key-dir "$ASSET_ROOT/hash-sig-keys"
    --log-level debug
)

if [ "$NETWORK_LABEL" = "devnet4" ] && [ -f "$ASSET_ROOT/annotated_validators.yaml" ]; then
    FLAGS+=(--validator-keys-path "$ASSET_ROOT/annotated_validators.yaml")
fi

if [ -n "${HIVE_CHECKPOINT_SYNC_URL:-}" ]; then
    FLAGS+=(--checkpoint-sync-url "$HIVE_CHECKPOINT_SYNC_URL")
fi

FLAGS+=(--devnet "$NETWORK_LABEL")

if [ "${HIVE_IS_AGGREGATOR:-0}" = "1" ]; then
    FLAGS+=(--is-aggregator)
fi

export LD_LIBRARY_PATH="$LANTERN_ROOT/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export RUST_LOG="${RUST_LOG:-info}"

exec "$LANTERN_BIN" "${FLAGS[@]}"
