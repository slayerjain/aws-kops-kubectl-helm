FROM alpine:3.6 as build
MAINTAINER Shubham Jain <shubhamkjain@outlook.com>

RUN apk add --update --no-cache ca-certificates git

ARG VERSION=v2.12.3
ARG FILENAME=helm-${VERSION}-linux-amd64.tar.gz

WORKDIR /

RUN apk add --update -t deps curl tar gzip
RUN curl -L http://storage.googleapis.com/kubernetes-helm/${FILENAME} | tar zxv -C /tmp

# The image we keep
FROM alpine

ENV KOPS_VERSION=1.8.1
ENV KUBECTL_VERSION=v1.10.0

COPY --from=build  /tmp/linux-amd64 /usr/local/bin

RUN apk add --update \
    ca-certificates \
    groff \
    less \
    python \
    py-pip \
    curl \
  && pip install awscli \
  && curl -LO --silent --show-error https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-linux-amd64 \
  && mv kops-linux-amd64 /usr/local/bin/kops \
  && curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
  && mv kubectl /usr/local/bin/kubectl \
  && chmod +x /usr/local/bin/kops /usr/local/bin/kubectl \
  && apk --purge -v del \
    py-pip \
    curl \
  && rm -rf /var/cache/apk/*
