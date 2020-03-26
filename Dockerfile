FROM golang:1.14.1 AS builder

RUN git clone https://github.com/rakyll/hey.git
RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 \
    go get -u github.com/rakyll/hey

FROM alpine

LABEL com.evgmoskalenko.project.name="alpine-kube-tools" \
      com.evgmoskalenko.description="An Alpine based docker image contains a good combination of commonly used tools\
      in Kubernetes cluster" \
      com.evgmoskalenko.project.source="https://github.com/evgmoskalenko/alpine-kube-tools" \
      com.evgmoskalenko.project.maintainer="eugene-msa@yandex.ru"

ARG AWS_CLI_VERSION=1.16.170
ARG AWS_IAM_AUTHENTICATOR_VERSION=1.15.10/2020-02-22
ARG KUBECTL_VERSION=1.18.0
ARG KUSTOMIZE_VERSION=3.4.0
ARG YQ_VERSION=3.2.1

COPY --from=builder /go/bin/hey /usr/local/bin

### Install tools
RUN apk --no-cache update && \
    apk --no-cache add git curl wget jq make bash ca-certificates groff less gawk sed grep bc coreutils && \
    rm -rf /var/cache/apk/*

### Install python
RUN apk add --no-cache python3 && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache

### Install aws-cli
RUN apk --no-cache update && \
    pip3 install --upgrade pip && \
    pip3 install -U setuptools && \
    pip3 install --no-cache-dir awscli==${AWS_CLI_VERSION} && \
    rm -rf /var/cache/apk/*

#### Install aws-iam-authenticator
RUN wget -q --no-check-certificate https://amazon-eks.s3-us-west-2.amazonaws.com/${AWS_IAM_AUTHENTICATOR_VERSION}/bin/linux/amd64/aws-iam-authenticator -O /usr/local/bin/aws-iam-authenticator && \
    chmod +x /usr/local/bin/aws-iam-authenticator && \
    aws-iam-authenticator version

### Install kubectl
RUN wget -q --no-check-certificate https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

### Install Kustomize
RUN wget --content-disposition https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz \
    && tar -xzvf kustomize_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz -C /usr/local/bin/ \
    && chmod +x /usr/local/bin/kustomize \
    && rm kustomize_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz

### Install YQ
RUN wget --content-disposition https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 \
    && chmod +x ./yq_linux_amd64 \
    && mv ./yq_linux_amd64 /usr/local/bin/yq

# Cleanup apt cache
RUN rm -rf /var/cache/apk/*

CMD ["bash"]
