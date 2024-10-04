# Copyright 2022 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

######## full image ########

FROM amazonlinux:2 as image

RUN amazon-linux-extras install aws-nitro-enclaves-cli -y
RUN yum update -y && \
    yum install -y \
    aws-nitro-enclaves-cli-dev \
    jq \
    wget \
    procps

RUN yum clean all

RUN if command -v nitro-cli > /dev/null 2>&1; then \
        echo "Command exists"; \
    else \
        find /ne-deps \
        echo "Command does not exist"; \
        exit 1; \
    fi

RUN wget https://github.com/containers/gvisor-tap-vsock/releases/download/v0.7.5/gvproxy-linux-amd64
RUN mv gvproxy-linux-amd64 gvproxy
RUN chmod +x gvproxy
RUN cp gvproxy /usr/bin

COPY bin/notary-server-nitriding.eif /home/notary-server.eif
COPY notary-nitriding/run.sh  /home

CMD ["/home/run.sh"]
