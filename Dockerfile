ARG UBUNTU_VERSION=26.04

FROM ubuntu:${UBUNTU_VERSION} AS build

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_CTYPE=C.UTF-8

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
    bison \
    build-essential \
    ca-certificates \
    gcc-multilib \
    git \
    libc6-dev-i386 \
    patch

COPY . /opt/movfuscator

RUN cd /opt/movfuscator && \
    ./build.sh && \
    ./install.sh

FROM ubuntu:${UBUNTU_VERSION}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_CTYPE=C.UTF-8

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
    binutils \
    cpp \
    libc6-dev-i386

COPY --from=build /opt/movfuscator /opt/movfuscator

RUN ln -sfn /opt/movfuscator/build/movcc /usr/local/bin/movcc

WORKDIR /work

ENTRYPOINT ["movcc"]
