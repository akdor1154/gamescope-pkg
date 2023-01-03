FROM docker.io/ubuntu:22.04

RUN sed -ie 's/^# deb-src/deb-src/' /etc/apt/sources.list

RUN apt-get -y update \
    && apt-get -y install build-essential
    
RUN apt-get -y build-dep libwayland-server0

RUN apt-get -y install devscripts sudo

RUN apt-get -y build-dep libdrm
