FROM gcc:8.2.0 AS builder

# Creates a docker image, wihtout mysql and webhook support. Expects a storage.cfg and autoexec_server.cfg under /data.
#TODO: Autoexec log file, maps download, mysql support

ARG CMAKEOPTIONS='-DCLIENT=OFF -DPREFER_BUNDLED_LIBS=ON -DDEV=OFF -DCMAKE_BUILD_TYPE=Release'
ARG MAKEOPTIONS='DDNet-Server'

ADD . /code/
WORKDIR /code/

RUN apt-get update && \
    apt-get install -y cmake && \
    apt-get install -y cmake libcurl4-openssl-dev && \
    # git clone --progress https://github.com/ddnet/ddnet.git && \
    mkdir -p build && \
    cd build && \
    cmake .. $CMAKEOPTIONS && \
    make $MAKEOPTIONS

FROM frolvlad/alpine-glibc:latest

RUN addgroup -S ddnet && adduser -S -H ddnet -G ddnet

COPY --from=builder --chown=ddnet:ddnet "/code/build/DDNet-Server" "/app/"
COPY "entrypoint.sh" "/app/"

VOLUME /data/
EXPOSE 8303/udp

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["./DDNet-Server"]
