# Copied originally from
# https://github.com/collectd/collectd/blob/master/contrib/docker/Dockerfile
FROM debian:stable

ARG BUILD_DATE
ARG VCS_REF
ARG BRANCH
ARG TAG


ENV DEBIAN_FRONTEND noninteractive
COPY 50docker-apt-conf /etc/apt/apt.conf.d/

COPY rootfs_prefix/ /usr/src/rootfs_prefix/

RUN apt-get update \
 && apt-get upgrade \
 && apt-get install \
    collectd-core \
    collectd-utils \
    build-essential \
 && make -C /usr/src/rootfs_prefix/ \
 && apt-get --purge remove build-essential \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY collectd.conf /etc/collectd/collectd.conf
COPY collectd.conf.d /etc/collectd/collectd.conf.d

ENV LD_PRELOAD /usr/src/rootfs_prefix/rootfs_prefix.so

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/kbase/docker-collectd.git" \
      org.label-schema.vcs-ref=$COMMIT \
      org.label-schema.schema-version="1.0.0-rc1" \
      us.kbase.vcs-branch=$BRANCH  \
      maintainer="Steve Chan sychan@lbl.gov"

CMD [ "/usr/sbin/collectd", "-f"]
