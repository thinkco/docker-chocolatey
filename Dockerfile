FROM mono:5.20.1.19

MAINTAINER Carlos Lozano Diez <thinkcode@adaptive.me>

RUN apt-get update && \
    apt-get install -y wget && \
    rm -rf /var/lib/apt/lists/* /tmp/*

RUN wget https://github.com/chocolatey/choco/archive/0.10.13.tar.gz && \
    tar xvfz 0.10.13.tar.gz && \
    ls -lart

COPY . /usr/local/src/choco/

WORKDIR /usr/local/src/choco
RUN chmod +x build.sh
RUN chmod +x zip.sh
RUN ./build.sh

WORKDIR /usr/local/bin
RUN ln -s /usr/local/src/choco/build_output/chocolatey

COPY docker/choco_wrapper /usr/local/bin/choco

WORKDIR /root
