FROM mono:3.12.1 as build

ARG CHOCO_VERSION=stable

WORKDIR /usr/local/src
RUN curl -s -L https://github.com/chocolatey/choco/archive/${CHOCO_VERSION}.tar.gz --output ${CHOCO_VERSION}.tar.gz
RUN tar -xzf ${CHOCO_VERSION}.tar.gz
RUN mv choco-${CHOCO_VERSION} choco

WORKDIR /usr/local/src/choco
RUN chmod +x build.sh zip.sh
RUN ./build.sh -v

FROM debian

RUN apt update && apt install -y mono-devel && apt-get clean all
COPY --from=build /usr/local/src/choco/build_output/chocolatey /opt/chocolatey
RUN echo "#!/bin/bash" >> /usr/bin/choco && \
    echo "set -e" >> /usr/bin/choco && \
    echo " " >> /usr/bin/choco && \
    echo "function cleanup {" >> /usr/bin/choco && \
    echo "	if [ $PWD != "/" ] && [ -d opt ]; then" >> /usr/bin/choco && \
    echo "		rm -rf opt" >> /usr/bin/choco && \
    echo "	fi" >> /usr/bin/choco && \
    echo "}" >> /usr/bin/choco && \
    echo "trap cleanup EXIT" >> /usr/bin/choco && \
    echo " " >> /usr/bin/choco && \
    echo "mono /opt/chocolatey/choco.exe "$@" --allow-unofficial" >> /usr/bin/choco && \
    chmod +x /usr/bin/choco && \
    mkdir -p /opt/chocolatey/lib

ENTRYPOINT ["/usr/bin/choco"]
CMD ["-h"]