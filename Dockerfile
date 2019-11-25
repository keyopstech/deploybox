FROM alpine:3.9
MAINTAINER Mickael VILLERS <mickael@keyops.tech>

# Note: Latest version of kubectl may be found at:
# https://aur.archlinux.org/packages/kubectl-bin/
ENV KUBE_LATEST_VERSION="v1.16.0"

# Note: Latest version of helm may be found at:
# https://github.com/kubernetes/helm/releases
ENV HELM_VERSION="v2.13.0"

# Note: Latest version of google-cloud-sdk may be found at:
# https://aur.archlinux.org/packages/google-cloud-sdk/
ENV CLOUD_SDK_VERSION="237.0.0"

ENV PATH /google-cloud-sdk/bin:$PATH

# Install tools
RUN apk add --no-cache \
        sudo \
        wget \
        curl \
        ca-certificates \
        python \
        py-pip \
        openssl \
        openssh \
        bash \
        git

# Install Ansible
RUN apk add --no-cache --virtual .build-dependencies \
        python-dev \
        libffi-dev \
        openssl-dev \
        build-base \
    && pip install --upgrade pip cffi ansible requests google-auth \
    && apk del .build-dependencies

# Install Kubectl and Helm
RUN wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && wget -q https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm

# Install google-cloud-sdk
RUN wget -q https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
    && tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
    && rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
    && ln -s /lib /lib6 \
    && gcloud config set core/disable_usage_reporting true \
    && gcloud config set component_manager/disable_update_check true
