# Copyright 2018, Development Gateway, see COPYING
FROM python:2.7-alpine

RUN apk add --no-cache --virtual .build-deps make git

RUN git clone -v https://github.com/rpm-software-management/createrepo.git build \
  && cd build \
  && git checkout createrepo-0-10-4

ADD makefile.patch build

RUN cd build \
  && patch -p1 <makefile.patch \
  && make DESTDIR=/ sysconfdir=/etc install

RUN ln -sf /usr/local/bin/python /usr/bin/python
