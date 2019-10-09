FROM golang@sha256:9395b4f89af7f5453bd7c6dbbd103085ecc4270e290a9121fe8fc11f74171035
ARG appVersion=latest
RUN apk --no-cache add git ca-certificates
ADD . /go/src/github.com/flant/shell-operator
RUN go get -d github.com/flant/shell-operator/...
WORKDIR /go/src/github.com/flant/shell-operator
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w -X 'github.com/flant/shell-operator/pkg/app.Version=$appVersion'" -o shell-operator ./cmd/shell-operator

FROM alpine@sha256:1032bdba4c5f88facf7eceb259c18deb28a51785eb35e469285a03eba78dd3fc
RUN apk --no-cache add ca-certificates jq bash && \
    wget https://storage.googleapis.com/kubernetes-release/release/v1.13.5/bin/linux/arm64/kubectl -O /bin/kubectl && \
    chmod +x /bin/kubectl && \
    mkdir /hooks
COPY --from=0 /go/src/github.com/flant/shell-operator/shell-operator /
WORKDIR /
ENV SHELL_OPERATOR_WORKING_DIR /hooks
ENTRYPOINT ["/shell-operator"]
CMD ["start"]
