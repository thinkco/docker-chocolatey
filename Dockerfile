FROM mono:5.20.1.19

MAINTAINER Carlos Lozano Diez <thinkcode@adaptive.me>

ENV CHOCO_VERSION=0.10.13

RUN apt-get update && \
    apt-get install -y wget && \
    rm -rf /var/lib/apt/lists/* /tmp/*

RUN mkdir -p /workdir && \
    cd /workdir && \
    wget https://github.com/chocolatey/choco/archive/$CHOCO_VERSION.tar.gz && \
    tar xvfz $CHOCO_VERSION.tar.gz && \
    rm $CHOCO_VERSION.tar.gz && \
    mv choco-$CHOCO_VERSION /usr/local/src/choco && \
    rm -Rf /workdir

WORKDIR /usr/local/src/choco
RUN chmod +x build.sh
RUN chmod +x zip.sh
RUN ./build.sh

WORKDIR /usr/local/bin
RUN ln -s /usr/local/src/choco/build_output/chocolatey

COPY docker/choco_wrapper /usr/local/bin/choco

WORKDIR /root
