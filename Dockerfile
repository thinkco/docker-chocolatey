FROM registry.adaptive.me/thinkcode/docker-mono:latest as build

ARG CHOCO_VERSION=stable

WORKDIR /usr/local/src
RUN wget -q https://github.com/chocolatey/choco/archive/${CHOCO_VERSION}.tar.gz
RUN tar -xzf ${CHOCO_VERSION}.tar.gz
RUN mv choco-${CHOCO_VERSION} choco

WORKDIR /usr/local/src/choco
RUN chmod +x build.sh zip.sh
RUN ./build.sh -v

FROM registry.adaptive.me/thinkcode/docker-mono:latest

RUN apt update && apt install -y mono-devel && apt-get clean all
COPY --from=builder /usr/local/src/choco/build_output/chocolatey /opt/chocolatey
COPY bin/choco /usr/bin/choco

ENTRYPOINT ["/usr/bin/choco"]
CMD ["-h"]