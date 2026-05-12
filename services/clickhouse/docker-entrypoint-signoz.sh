#!/bin/bash
set -e

# ── 1. Generate cluster.xml from env vars ──────────────────────────────────────
ZOOKEEPER_HOST="${ZOOKEEPER_HOST:-zookeeper}"
ZOOKEEPER_PORT="${ZOOKEEPER_PORT:-2181}"
CLICKHOUSE_HOST="${CLICKHOUSE_HOST:-clickhouse}"
CLICKHOUSE_PORT="${CLICKHOUSE_PORT:-9000}"

echo "Generating cluster.xml (ZooKeeper=${ZOOKEEPER_HOST}:${ZOOKEEPER_PORT}, CH=${CLICKHOUSE_HOST}:${CLICKHOUSE_PORT})"

cat > /etc/clickhouse-server/config.d/cluster.xml <<EOF
<?xml version="1.0"?>
<clickhouse>
    <zookeeper>
        <node index="1">
            <host>${ZOOKEEPER_HOST}</host>
            <port>${ZOOKEEPER_PORT}</port>
        </node>
    </zookeeper>
    <remote_servers>
        <cluster>
            <shard>
                <replica>
                    <host>${CLICKHOUSE_HOST}</host>
                    <port>${CLICKHOUSE_PORT}</port>
                </replica>
            </shard>
        </cluster>
    </remote_servers>
</clickhouse>
EOF

# ── 2. Download histogram-quantile binary (if not already present) ─────────────
HIST_BINARY="/var/lib/clickhouse/user_scripts/histogramQuantile"
if [ ! -f "${HIST_BINARY}" ]; then
    VERSION="v0.0.1"
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
    echo "Downloading histogram-quantile for ${OS}/${ARCH}..."
    mkdir -p /var/lib/clickhouse/user_scripts
    cd /tmp
    wget -q -O histogram-quantile.tar.gz \
        "https://github.com/SigNoz/signoz/releases/download/histogram-quantile%2F${VERSION}/histogram-quantile_${OS}_${ARCH}.tar.gz"
    tar -xzf histogram-quantile.tar.gz
    mv histogram-quantile "${HIST_BINARY}"
    chmod +x "${HIST_BINARY}"
    echo "histogram-quantile installed at ${HIST_BINARY}"
fi

# ── 3. Hand off to the official ClickHouse entrypoint ─────────────────────────
exec /entrypoint.sh "$@"
