############################
# STEP 1 build executable binary
############################
FROM golang:alpine AS builder
USER root
RUN apk update && apk add --no-cache git bash wget curl
WORKDIR /go/src/v2ray.com/core
RUN git clone --progress https://github.com/v2fly/v2ray-core.git . && \
    bash ./release/user-package.sh nosource noconf codename=$(git describe --tags) buildname=docker-fly abpathtgz=/tmp/v2ray.tgz
############################
# STEP 2 build a small image
############################
FROM alpine
USER root
LABEL maintainer "V2Fly Community <vcptr@v2fly.org>"
COPY --from=builder /tmp/v2ray.tgz /tmp
COPY config.json /etc/v2ray/
RUN apk update && apk add ca-certificates && \
    mkdir -p /usr/bin/v2ray && \
    tar xvfz /tmp/v2ray.tgz -C /usr/bin/v2ray && \
    chmod +x /usr/bin/v2ray/v2ctl && \
    chmod +x /usr/bin/v2ray/v2ray && \
    ls -l /usr/bin/v2ray/ && \
    mkdir -p /etc/v2ray && \
    cat /etc/v2ray/config.json
    chgrp -R 0 /usr/bin/v2ray && \
        chmod -R g=u /usr/bin/v2ray && \
    chgrp -R 0 /etc/v2ray && \
        chmod -R g=u /etc/v2ray

#ENTRYPOINT ["/usr/bin/v2ray/v2ray"]
ENV PATH /usr/bin/v2ray:$PATH
CMD ["v2ray", "-config=/etc/v2ray/config.json"]
