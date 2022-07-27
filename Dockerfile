FROM golang:1.14.8-stretch as build
LABEL maintainer="Infinity Works"

ENV GO111MODULE=on

COPY ./ /go/src/github.com/infinityworks/github-exporter
WORKDIR /go/src/github.com/infinityworks/github-exporter

RUN go mod download \
    && go test ./... \
    && CGO_ENABLED=0 GOOS=linux go build -o /bin/main

#FROM registry.access.redhat.com/ubi8/ubi@sha256:798025840cb82140df8d05775f7f55fff3b16a599bd5ca76b11594f7a9a595fa
FROM registry.access.redhat.com/ubi8/ubi@sha256:68fecea0d255ee253acbf0c860eaebb7017ef5ef007c25bee9eeffd29ce85b29

RUN yum install -y ca-certificates \ 
    && groupadd exporter \
    && useradd -s /bin/bash -g exporter exporter

ADD VERSION .
USER exporter

COPY --from=build /bin/main /bin/main

ENV LISTEN_PORT=9171
EXPOSE 9171
ENTRYPOINT [ "/bin/main" ]
