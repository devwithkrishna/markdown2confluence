FROM golang:1.26-alpine AS builder

WORKDIR /go/src/

RUN apk add --no-cache git curl && \
    git config --global advice.detachedHead false && \
    TAG=$(curl --silent "https://api.github.com/repos/kovetskiy/mark/releases/latest" \
    | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/') && \
    git clone --depth 1 --branch ${TAG} https://github.com/kovetskiy/mark.git

WORKDIR /go/src/mark

RUN go mod tidy && \
    ARCH="$(uname -m)" ; \
    case "${ARCH}" in \
      aarch64|arm64) ARCH=arm64 ;; \
      x86_64|amd64) ARCH=amd64 ;; \
      *) echo "Unsupported arch: ${ARCH}" >&2; exit 1 ;; \
    esac && \
    GOOS=$(uname -s | tr '[:upper:]' '[:lower:]') && \
    env GOOS="$GOOS" GOARCH="$ARCH" CGO_ENABLED=0 \
    go build -trimpath -ldflags="-s -w" -o /go/mark ./cmd/mark

RUN /go/mark --help >/dev/null

FROM alpine:latest 

COPY --chmod=0755 --from=builder /go/mark /usr/bin/mark
COPY --chmod=0755 entrypoint.sh /app/entrypoint.sh

RUN apk update && apk add --no-cache ca-certificates bash && \
    addgroup -S noroot && adduser -S -G noroot noroot

WORKDIR /workspace
USER noroot

ENTRYPOINT [ "/app/entrypoint.sh" ]