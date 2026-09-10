FROM golang:1.25-alpine AS builder

WORKDIR /src

RUN apk add --no-cache git

RUN git clone --depth 1 https://github.com/jpillora/chisel.git .

RUN CGO_ENABLED=0 GOOS=linux go build \
    -trimpath \
    -ldflags="-s -w" \
    -o /chisel .

FROM alpine:3.22

RUN apk add --no-cache ca-certificates

COPY --from=builder /chisel /usr/local/bin/chisel

RUN adduser -D -H chisel

USER chisel

ENTRYPOINT ["sh", "-c"]
CMD ["exec chisel server --host 0.0.0.0 --port \"$PORT\" --auth \"admin:$CHISEL_PASSWORD\" --reverse"]
