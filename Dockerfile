FROM golang:1.10 as builder

COPY . /go/src/github.com/Datadog/kube-sync

RUN make -C /go/src/github.com/Datadog/kube-sync re

FROM busybox:latest

COPY --from=builder /go/src/github.com/Datadog/kube-sync/kube-sync /usr/local/bin/kube-sync
