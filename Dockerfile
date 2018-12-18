# Copyright 2018, Development Gateway, see COPYING
FROM python:2.7-alpine

ARG RPM_VERSION=4.14.0
ARG UG_VERSION=3-10-2
ARG UG_MIRROR=https://github.com/rpm-software-management/urlgrabber/archive
ARG YUM_VERSION=3.4.3
ARG YUM_MIRROR=http://yum.baseurl.org/download/3.4
ARG CR_VERSION=0-10-4
ARG CR_MIRROR=https://github.com/rpm-software-management/createrepo/archive
ARG MP_VERSION=master
ARG MP_MIRROR=https://github.com/rpm-software-management/yum-metadata-parser/archive
ARG DR_VERSION=3.6.1
ARG DR_MIRROR=https://github.com/rpm-software-management/deltarpm/archive

RUN ln -sf /usr/local/bin/python /usr/bin/python

RUN set -o pipefail; \
  apk add --no-cache zlib libmagic popt libarchive db nss \
  && apk add --no-cache --virtual .build-deps git libtool automake autoconf make gcc \
    libc-dev gettext-dev zlib-dev file-dev popt-dev libarchive-dev db-dev nss-dev curl curl-dev \
  && wget -O - http://ftp.rpm.org/releases/rpm-4.14.x/rpm-${RPM_VERSION}.tar.bz2 \
    | tar -xjf - -C /tmp \
  && cd /tmp/rpm-${RPM_VERSION} \
  && sed -i '800 s/-${PYTHON_VERSION}/2/' configure.ac \
  && ./autogen.sh --prefix=/usr --enable-python --without-lua \
  && make CFLAGS='-lintl -include signal.h' install \
  && rm -rf /tmp/rpm-${RPM_VERSION}

RUN set -o pipefail; \
  wget -O - ${CR_MIRROR}/createrepo-${CR_VERSION}.tar.gz \
    | tar -xzf - -C /tmp \
  && cd /tmp/createrepo-createrepo-${CR_VERSION} \
  && sed -i '/\<install\>/ s/ --verbose//' Makefile bin/Makefile docs/Makefile \
  && make DESTDIR=/ install \
  && rm -rf /tmp/createrepo-createrepo-${CR_VERSION}

RUN set -o pipefail; \
  wget -O - ${UG_MIRROR}/urlgrabber-${UG_VERSION}.tar.gz \
    | tar -xzf - -C /tmp \
  && cd /tmp/urlgrabber-urlgrabber-${UG_VERSION} \
  && python setup.py install \
  && rm -rf /tmp/urlgrabber-urlgrabber-${UG_VERSION}

RUN set -o pipefail; \
  wget -O - ${YUM_MIRROR}/yum-${YUM_VERSION}.tar.gz \
    | tar -xzf - -C /tmp \
  && cd /tmp/yum-${YUM_VERSION} \
  && make DESTDIR=/ install

RUN pip install pycurl

RUN set -o pipefail; \
  apk add glib-dev libxml2-dev sqlite-dev \
  && wget -O - ${MP_MIRROR}/${MP_VERSION}.tar.gz \
    | tar -xzf - -C /tmp \
  && cd /tmp/yum-metadata-parser-${MP_VERSION} \
  && python setup.py build \
  && python setup.py install --prefix=/usr \
  && rm -rf /tmp/yum-metadata-parser-${MP_VERSION}

RUN set -o pipefail; \
  && wget -O - ${DR_MIRROR}/${DR_VERSION}.tar.gz \
    | tar -xzf - -C /tmp \
  && cd /tmp/deltarpm-${DR_VERSION} \
  && apk add xz-dev \
  && make python \
  && make prefix=/usr install \
  && rm -rf /tmp/deltarpm-${DR_VERSION}

RUN find /usr/share/man -mindepth 1 -delete \
  && rm -rf /etc/bash_completion.d

RUN apk del .build-deps
