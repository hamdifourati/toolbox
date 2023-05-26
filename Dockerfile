FROM ubuntu:22.10
LABEL maintainer "Hamdi Fourati <contact@hamdifourati.info>"

WORKDIR /toolbox

RUN mkdir /toolbox/bin
ENV PATH=$PATH:/toolbox/bin
RUN echo 'export PATH=$PATH:/toolbox/bin:/toolbox/google-cloud-sdk/bin' >> /root/.bashrc

# Install tools
RUN apt -qq update && \
    apt -qq install -y tmux vim jq unzip tar curl openssh-client \
    python3 python3-dev python3-pip build-essential \
    git wget graphviz less

# Ansible
ENV ANSIBLE_VERSION=2.15.0
RUN pip -q install ansible-core==${ANSIBLE_VERSION}

# Terraform
ENV TERRAFORM_VERSION=1.4.6
RUN wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
   unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /toolbox/bin && \
   rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Kubectl
ENV KUBECTL_VERSION=1.26.4
RUN curl -sLO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    install kubectl /toolbox/bin/ && rm kubectl

# Helm
ENV HELM_VERSION=3.12.0
RUN wget -q https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
   tar xavf helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
   install linux-amd64/helm /toolbox/bin/ && rm -rf helm-* linux-amd64/

# GCLOUD
ENV GCLOUD_VERSION=431.0.0
ENV PATH=$PATH:/toolbox/google-cloud-sdk/bin
ENV CLOUDSDK_CORE_DISABLE_PROMPTS=1

RUN wget -q https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz && \
    tar xaf google-cloud-sdk-*.tar.gz --directory /toolbox/ && \
    rm google-cloud-sdk-*.tar.gz && \
    gcloud components install gke-gcloud-auth-plugin && \
    gcloud --quiet --verbosity=error components update

# AWS
ENV AWS_CLI_VERSION=2.11.21
RUN apt -qq update && apt -qq install -y groff
RUN curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip" && \
  unzip -qq awscliv2.zip && \
  ./aws/install && rm -r awscliv2.zip aws

COPY files/config /root/.aws/config
COPY files/credentials /root/.aws/credentials

CMD ["tmux"]
