# cluster.xml template — generated at container start by docker-entrypoint-signoz.sh
# This file is not used directly; the entrypoint generates cluster.xml from env vars.
# Kept as reference only.
<?xml version="1.0"?>
<clickhouse>
    <zookeeper>
        <node index="1">
            <host>ZOOKEEPER_HOST_PLACEHOLDER</host>
            <port>ZOOKEEPER_PORT_PLACEHOLDER</port>
        </node>
    </zookeeper>
    <remote_servers>
        <cluster>
            <shard>
                <replica>
                    <host>CLICKHOUSE_HOST_PLACEHOLDER</host>
                    <port>CLICKHOUSE_PORT_PLACEHOLDER</port>
                </replica>
            </shard>
        </cluster>
    </remote_servers>
</clickhouse>
