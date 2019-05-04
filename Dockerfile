FROM mono:latest as builder

MAINTAINER Carlos Lozano Diez <thinkcode@adaptive.me>

ARG CHOCO_VERSION=stable

RUN apt-get -qq update && apt-get -qq install -y wget tar gzip mono-reference-assemblies-3.5 mono-reference-assemblies-4.0

WORKDIR /usr/local/src
RUN wget -q "https://github.com/chocolatey/choco/archive/${CHOCO_VERSION}.tar.gz"
RUN tar -xzf "${CHOCO_VERSION}.tar.gz"
RUN mv "choco-${CHOCO_VERSION}" choco
run cp -Rf /usr/lib/mono/3.5-api /usr/lib/mono/4.0
RUN ls -lart /usr/lib/mono/

WORKDIR /usr/local/src/choco
RUN chmod +x build.sh zip.sh
RUN ./build.sh -v


FROM debian

RUN apt update && apt install -y mono-devel && apt-get clean all
COPY --from=builder /usr/local/src/choco/build_output/chocolatey /opt/chocolatey
COPY bin/choco /usr/bin/choco

ENTRYPOINT ["/usr/bin/choco"]
CMD ["-h"]
