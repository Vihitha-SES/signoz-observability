FROM clickhouse/clickhouse-server:25.5.6

# Copy ClickHouse server configs
COPY config.xml          /etc/clickhouse-server/config.xml
COPY users.xml           /etc/clickhouse-server/users.xml
COPY custom-function.xml /etc/clickhouse-server/custom-function.xml

# cluster.xml is generated at runtime from env vars by docker-entrypoint-signoz.sh
# so we only copy the template
COPY cluster.xml.tpl     /etc/clickhouse-server/config.d/cluster.xml.tpl

# Entrypoint script: generates cluster.xml, downloads histogram binary, then starts CH
COPY docker-entrypoint-signoz.sh /docker-entrypoint-signoz.sh
RUN chmod +x /docker-entrypoint-signoz.sh

# HTTP API | native TCP | inter-server
EXPOSE 8123 9000 9009

ENV CLICKHOUSE_SKIP_USER_SETUP=1 \
    # ZooKeeper host — set to your Railway ZooKeeper service
    # Example: zookeeper.railway.internal
    ZOOKEEPER_HOST=zookeeper \
    ZOOKEEPER_PORT=2181

ENTRYPOINT ["/docker-entrypoint-signoz.sh"]
