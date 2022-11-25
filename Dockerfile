FROM gcr.io/projectsigstore/cosign:v1.13.0 as cosign-bin

# 3.17.0
FROM alpine@sha256:8914eb54f968791faf6a8638949e480fef81e697984fba772b3976835194c6d4

COPY --from=cosign-bin /ko-app/cosign /usr/local/bin/cosign

# https://dl.k8s.io/release/stable.txt
# https://github.com/helm/helm/releases
ENV \
    KUBECTL_VERSION=v1.25.4 \
    HELM_VERSION=v3.10.2

RUN \
    case $(apk --print-arch) in \
      aarch64) \
        export ARCH='arm64'; \
        export KUBECTL_SHA256='a8e9cd3c6ca80b67091fc41bc7fe8e9f246835925c835823a08a20ed9bcea1ba'; \
        export HELM_SHA256='57fa17b6bb040a3788116557a72579f2180ea9620b4ee8a9b7244e5901df02e4'; \
      ;; \
      x86_64) \
        export ARCH='amd64'; \
        export KUBECTL_SHA256='e4e569249798a09f37e31b8b33571970fcfbdecdd99b1b81108adc93ca74b522'; \
        export HELM_SHA256='2315941a13291c277dac9f65e75ead56386440d3907e0540bf157ae70f188347'; \
      ;; \
    esac; \
    \
    apk update && \
    apk upgrade && \
    apk add curl && \
    \
    echo "Installing kubectl for ${ARCH}" && \
    cd /tmp && \
    curl -sSLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl" && \
    echo "${KUBECTL_SHA256}  kubectl" | sha256sum -c && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    \
    echo "Installing Helm for ${ARCH}" && \
    curl -sSLO "https://get.helm.sh/helm-${HELM_VERSION}-linux-${ARCH}.tar.gz" && \
    echo "${HELM_SHA256}  helm-${HELM_VERSION}-linux-${ARCH}.tar.gz" | sha256sum -c && \
    tar xvf "helm-${HELM_VERSION}-linux-${ARCH}.tar.gz" --strip-components 1 linux-${ARCH}/helm && \
    install -o root -g root -m 0755 helm /usr/local/bin/helm && \
    \
    echo "Cleaning temp files" && \
    rm /tmp/helm* /tmp/kubectl /var/cache/apk/APKINDEX.*.tar.gz

USER 1000
