# Copied originally from
# https://github.com/collectd/collectd/blob/master/contrib/docker/Dockerfile
FROM debian:stable as build

ENV DEBIAN_FRONTEND noninteractive
COPY rootfs_prefix/ /usr/src/rootfs_prefix/

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y collectd-core collectd-utils build-essential git \
 && make -C /usr/src/rootfs_prefix \
 && cd /tmp \
 && git clone https://github.com/sychan/xswap_jgi

FROM kbase/kb_minideb:stretch

ARG BUILD_DATE
ARG VCS_REF
ARG BRANCH
ARG TAG

ENV DEBIAN_FRONTEND noninteractive
COPY 50docker-apt-conf /etc/apt/apt.conf.d/

RUN apt-get update \
    && apt-get upgrade \
    && apt-get install -y --allow-unauthenticated collectd-core collectd-utils libpython2.7 python-minimal python-pip python-setuptools \
    && pip install collectd docker \
    && apt-get remove python-setuptools python-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
   

COPY collectd.conf /etc/collectd/collectd.conf
COPY collectd.conf.d /etc/collectd/collectd.conf.d
COPY --from=build /usr/src/rootfs_prefix/rootfs_prefix.so /usr/src/rootfs_prefix/rootfs_prefix.so
COPY --from=build /tmp/xswap_jgi/kbase/collectd /root/collectd
COPY deployment/ /kb/deployment/

ENV LD_PRELOAD /usr/src/rootfs_prefix/rootfs_prefix.so

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/kbase/docker-collectd.git" \
      org.label-schema.vcs-ref=$COMMIT \
      org.label-schema.schema-version="1.0.0-rc1" \
      us.kbase.vcs-branch=$BRANCH  \
      maintainer="Steve Chan sychan@lbl.gov"

ENTRYPOINT [ "/kb/deployment/bin/dockerize" ]
CMD [ "-template", "/kb/deployment/conf/.templates/collectd.conf.templ:/etc/collectd/collectd.conf", \
      "/usr/sbin/collectd", "-f"]
