ARG VERSION_PYTHON
ARG VERSION_ALPINE

FROM python:${VERSION_PYTHON}-alpine${VERSION_ALPINE}

ARG VERSION_PYINSTALLER
ARG TARGET_BIN_DIR

# Official Python base image is needed or some applications will segfault.
# PyInstaller needs zlib-dev, gcc, libc-dev, and musl-dev
RUN apk --update --no-cache add \
    libffi-dev \
    zlib-dev \
    musl-dev \
    libc-dev \
    pwgen \
    make \
    gcc \
    g++ \
    git

# Install pycrypto so --key can be used with PyInstaller
RUN pip install --upgrade pip \
 && pip install \
    pycrypto

ADD ./bin ${TARGET_BIN_DIR}
RUN chmod a+x ${TARGET_BIN_DIR}/*

# Build bootloader for alpine
ENV PYINSTALLER_TAG v${VERSION_PYINSTALLER}
RUN git clone --depth 1 --single-branch --branch ${PYINSTALLER_TAG} https://github.com/pyinstaller/pyinstaller.git /tmp/pyinstaller \
 && cd /tmp/pyinstaller/bootloader \
 && CFLAGS="-Wno-stringop-overflow" python ./waf configure --no-lsb all \
 && pip install .. \
 && rm -Rf /tmp/pyinstaller

# Fixed entrypoint script
RUN echo '#!/bin/sh' > /entrypoint.sh \
 && echo "exec ${TARGET_BIN_DIR}/pyinstaller.sh \$@" >> /entrypoint.sh \
 && chmod a+x /entrypoint.sh

WORKDIR /src

ENTRYPOINT [ "/entrypoint.sh" ]
