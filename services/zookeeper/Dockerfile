FROM signoz/zookeeper:3.7.1

USER root

# ZooKeeper client | follower | election | Prometheus metrics
EXPOSE 2181 2888 3888 9141

ENV ZOO_SERVER_ID=1 \
    ALLOW_ANONYMOUS_LOGIN=yes \
    ZOO_AUTOPURGE_INTERVAL=1 \
    ZOO_ENABLE_PROMETHEUS_METRICS=yes \
    ZOO_PROMETHEUS_METRICS_PORT_NUMBER=9141 \
    ZOO_DATA_DIR=/bitnami/zookeeper

VOLUME ["/bitnami/zookeeper"]
