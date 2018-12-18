# Copyright 2018, Development Gateway, see COPYING
FROM python:2.7-alpine

ARG RPM_VERSION=4.14.0
ARG CR_VERSION=0-10-4
ARG CR_MIRROR=https://github.com/rpm-software-management/createrepo/archive

RUN apk add \
    zlib \
    libmagic \
    popt \
    libarchive \
    db \
    nss

RUN apk add --no-cache --virtual .build-deps \
    git \
    libtool \
    automake \
    autoconf \
    make \
    gcc \
    libc-dev \
    gettext-dev \
    zlib-dev \
    file-dev \
    popt-dev \
    libarchive-dev \
    db-dev \
    nss-dev

RUN ln -sf /usr/local/bin/python /usr/bin/python

RUN set -o pipefail; \
  wget -O - http://ftp.rpm.org/releases/rpm-4.14.x/rpm-${RPM_VERSION}.tar.bz2 \
  | tar -xjf - -C /tmp \
  && cd /tmp/rpm-${RPM_VERSION} \
  && sed -i '800 s/-${PYTHON_VERSION}/2/' configure.ac \
  && ./autogen.sh --prefix=/usr --enable-python --without-lua \
  && make CFLAGS='-lintl -include signal.h' install \
  && find /usr/share/man -mindepth 1 -delete \
  && rm -rf /tmp/rpm-${RPM_VERSION}

RUN set -o pipefail; \
  wget -O - ${CR_MIRROR}/createrepo-${CR_VERSION}.tar.gz \
  | tar -xzf - -C /tmp \
  && cd /tmp/createrepo-createrepo-${CR_VERSION}

RUN cd /tmp/createrepo-createrepo-${CR_VERSION} \
  && sed -i '/\<install\>/ s/ --verbose//' Makefile bin/Makefile docs/Makefile \
  && make DESTDIR=/ install \
  && find /usr/share/man -mindepth 1 -delete \
  && rm -rf /etc/bash_completion.d
