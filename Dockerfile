FROM golang:1.25-alpine AS builder

WORKDIR /src

RUN apk add --no-cache git

RUN git clone --depth 1 https://github.com/jpillora/chisel.git .

RUN go version && \
    CGO_ENABLED=0 GOOS=linux go build \
    -trimpath \
    -ldflags="-s -w" \
    -o /chisel .

FROM alpine:3.22

RUN apk add --no-cache ca-certificates

COPY --from=builder /chisel /usr/local/bin/chisel

RUN adduser -D -H chisel

USER chisel

ENTRYPOINT ["chisel", "server"] 
CMD ["exec chisel server --port \"$PORT\" --auth \"admin:$CHISEL_PASSWORD\" --reverse"]

