FROM signoz/signoz-otel-collector:v0.144.3

# Copy collector configs
COPY otel-collector-config.yaml /etc/otel-collector-config.yaml
COPY manager-config.yaml        /etc/manager-config.yaml

# OTLP gRPC | OTLP HTTP | health_check
EXPOSE 4317 4318 13133

# Railway injects PORT — the otel collector doesn't use it directly,
# but we document it here for clarity. OTLP ports are fixed.
ENV OTEL_RESOURCE_ATTRIBUTES="host.name=signoz-host,os.type=linux" \
    LOW_CARDINAL_EXCEPTION_GROUPING="false" \
    SIGNOZ_OTEL_COLLECTOR_CLICKHOUSE_CLUSTER="cluster" \
    SIGNOZ_OTEL_COLLECTOR_CLICKHOUSE_REPLICATION="true" \
    SIGNOZ_OTEL_COLLECTOR_TIMEOUT="10m"

# Run schema migrations first, then start the collector
ENTRYPOINT ["/bin/sh", "-c", \
  "/signoz-otel-collector migrate sync check && \
   /signoz-otel-collector \
     --config=/etc/otel-collector-config.yaml \
     --manager-config=/etc/manager-config.yaml \
     --copy-path=/var/tmp/collector-config.yaml"]
