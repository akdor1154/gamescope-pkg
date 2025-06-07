FROM docker.io/ubuntu:24.04

RUN sed -Ei 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources
RUN rm -f /etc/apt/apt.conf.d/docker-clean

ADD http://archive.ubuntu.com/ubuntu/dists/plucky/Release apt_update_cachebust_plucky

RUN apt-get -y update \
    && apt-get -y install build-essential devscripts pkgconf

RUN apt-get -y build-dep \
    libwayland-server0 \
    wayland-protocols

COPY apt /etc/apt/
RUN apt-get -y update \
    && dpkg --clear-avail \
    && sync-available
