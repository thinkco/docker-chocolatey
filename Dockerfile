FROM ubuntu:trusty as build

ARG MONO_VERSION=3.12.0
ARG CHOCO_VERSION=stable

RUN apt -qq update && apt -qq upgrade -y && apt -qq install -y wget build-essential gettext file

WORKDIR /usr/local/src
RUN wget -q http://download.mono-project.com/sources/mono/mono-$MONO_VERSION.tar.bz2
RUN tar -xf mono-$MONO_VERSION.tar.bz2 && rm mono-$MONO_VERSION.tar.bz2

WORKDIR /usr/local/src/mono-$MONO_VERSION
RUN ./configure --prefix=/usr/local
RUN make
RUN make install
RUN mono --version

WORKDIR /usr/local/src
RUN wget -q https://github.com/chocolatey/choco/archive/${CHOCO_VERSION}.tar.gz
RUN tar -xzf ${CHOCO_VERSION}.tar.gz
RUN mv choco-${CHOCO_VERSION} choco

WORKDIR /usr/local/src/choco
RUN chmod +x build.sh zip.sh
RUN ./build.sh -v

FROM ubuntu:trusty

RUN apt update && apt install -y mono-devel && apt-get clean all
COPY --from=builder /usr/local/src/choco/build_output/chocolatey /opt/chocolatey
COPY bin/choco /usr/bin/choco

ENTRYPOINT ["/usr/bin/choco"]
CMD ["-h"]