FROM golang:1.22-alpine AS builder
WORKDIR /src
COPY main.go ./
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags='-s -w' -o /out/neox2-realm-probe-go

FROM alpine:3.20
WORKDIR /app
RUN adduser -S -D -H appuser
COPY --from=builder /out/neox2-realm-probe-go /usr/local/bin/neox2-realm-probe-go
ENV REALM=sony.net \
    PORT=3000
EXPOSE 3000
USER appuser
ENTRYPOINT ["/usr/local/bin/neox2-realm-probe-go"]

