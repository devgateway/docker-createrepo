# Copyright 2018, Development Gateway, see COPYING
FROM python:2.7-alpine

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

RUN git clone -v https://github.com/rpm-software-management/rpm.git /tmp/rpm \
  && cd /tmp/rpm \
  && git checkout -q rpm-4.14.0-release

COPY rpm-pkg-config-python.patch /tmp/

RUN cd /tmp/rpm \
  && patch -p1 </tmp/rpm-pkg-config-python.patch \
  && ./autogen.sh --prefix=/usr --enable-python --without-lua \
  && make CFLAGS='-lintl -include signal.h' install \
  && find /usr/share/man -mindepth 1 -delete

RUN git clone -v https://github.com/rpm-software-management/createrepo.git /tmp/createrepo \
  && cd /tmp/createrepo \
  && git checkout -q createrepo-0-10-4

COPY createrepo-makefile.patch /tmp/

RUN cd /tmp/createrepo \
  && patch -p1 </tmp/createrepo-makefile.patch \
  && make DESTDIR=/ sysconfdir=/etc install
