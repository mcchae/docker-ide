FROM mcchae/xfce
MAINTAINER MoonChang Chae mcchae@gmail.com
LABEL Description="alpine desktop env with ide (over xfce with novnc, xrdp and openssh server)"


################################################################################
# install python3
################################################################################
## if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 9.0.1
RUN apk add --no-cache python3
RUN set -ex; \
    apk add --no-cache --virtual .fetch-deps libressl; \
    wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'; \
    apk del .fetch-deps; \
    python3 get-pip.py \
        --disable-pip-version-check \
        --no-cache-dir \
        "pip==$PYTHON_PIP_VERSION" \
    ; \
    pip --version; \
    find /usr/local -depth \
        \( \
            \( -type d -a \( -name test -o -name tests \) \) \
            -o \
            \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
        \) -exec rm -rf '{}' +; \
    rm -f get-pip.py

################################################################################
# install openjdk8
################################################################################
RUN { \
        echo '#!/bin/sh'; \
        echo 'set -e'; \
        echo; \
        echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
    } > /usr/local/bin/docker-java-home \
    && chmod +x /usr/local/bin/docker-java-home
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

ENV JAVA_VERSION 8u151
ENV JAVA_ALPINE_VERSION 8.151.12-r0

RUN set -x \
    && apk add --no-cache \
        openjdk8="$JAVA_ALPINE_VERSION" \
    && [ "$JAVA_HOME" = "$(docker-java-home)" ]

################################################################################
# pycharm
################################################################################
WORKDIR /usr/local
ENV PYCHARM_VER pycharm-community-2017.3.3
RUN curl -SL https://download.jetbrains.com/python/$PYCHARM_VER.tar.gz | \
		tar -f - -xz --exclude "*/jre64" -f - \
    && ln -s /usr/local/$PYCHARM_VER /usr/local/pycharm

WORKDIR /

ADD chroot/usr /usr

