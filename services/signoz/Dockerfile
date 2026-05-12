# ──────────────────────────────────────────────────────────
# Stage 1: Build the Go backend binary
# ──────────────────────────────────────────────────────────
FROM golang:1.25-alpine AS go-builder

RUN apk add --no-cache git ca-certificates build-base

WORKDIR /app

# Copy go modules first for better layer caching
COPY go.mod go.sum ./
RUN go mod download

# Copy entire source
COPY . .

# Build the enterprise binary
RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags="-s -w" \
    -o /app/signoz-bin \
    ./cmd/enterprise

# ──────────────────────────────────────────────────────────
# Stage 2: Build the frontend
# ──────────────────────────────────────────────────────────
FROM node:22-alpine AS frontend-builder

WORKDIR /frontend

RUN corepack enable

COPY frontend/package.json frontend/yarn.lock frontend/i18-generate-hash.cjs ./
COPY frontend/scripts/ ./scripts/
RUN CI=true yarn install --frozen-lockfile --non-interactive

COPY frontend/ .
RUN npm run build

# ──────────────────────────────────────────────────────────
# Stage 3: Final minimal runtime image
# ──────────────────────────────────────────────────────────
FROM alpine:3.20.3

RUN apk add --no-cache ca-certificates wget

WORKDIR /root

# Copy backend binary
COPY --from=go-builder /app/signoz-bin /root/signoz

# Copy email templates
COPY templates/email /root/templates

# Copy built frontend
COPY --from=frontend-builder /frontend/dist /etc/signoz/web

# Copy default config (can be overridden via env vars or volume mount)
COPY services/signoz/config.yaml /etc/signoz/config.yaml

RUN chmod 755 /root/signoz

# SigNoz HTTP API + UI port
EXPOSE 8080

# Railway injects PORT; the patched code reads it automatically.
# You can also set HTTP_HOST_PORT=0.0.0.0:8080 explicitly.
ENV SIGNOZ_SQLSTORE_SQLITE_PATH=/var/lib/signoz/signoz.db \
    SIGNOZ_ALERTMANAGER_PROVIDER=signoz \
    SIGNOZ_WEB_DIRECTORY=/etc/signoz/web

ENTRYPOINT ["./signoz", "server", "--config", "/etc/signoz/config.yaml"]
