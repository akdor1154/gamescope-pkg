FROM docker.io/ubuntu:22.04

RUN sed -i -e 's/^# deb-src/deb-src/' /etc/apt/sources.list
RUN rm -f /etc/apt/apt.conf.d/docker-clean

RUN apt-get -y update \
    && apt-get -y install build-essential devscripts

RUN apt-get -y build-dep \
    libdrm \
    libwayland-server0 \
    wayland-protocols \
    libvulkan-dev
