ARG GOLANG_VERSION
ARG ALPINE_VERSION

# build
FROM golang:${GOLANG_VERSION}-alpine${ALPINE_VERSION} AS builder

RUN apk --no-cache add make git; \
    adduser -D -h /tmp/dummy dummy

USER dummy

WORKDIR /tmp/dummy

COPY --chown=dummy Makefile Makefile
COPY --chown=dummy go.mod go.mod

RUN go mod download

ARG APPNAME

COPY --chown=dummy main.go main.go

RUN make build

# execute
FROM alpine:${ALPINE_VERSION}

ARG APPNAME

ARG APP_PATH
WORKDIR ${APP_PATH}

ENV SERVER_PORT ""

COPY --from=builder /tmp/dummy/${APPNAME} ${APPNAME}

CMD ["./https-web-server"]
