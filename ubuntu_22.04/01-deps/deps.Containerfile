FROM docker.io/ubuntu:22.04

RUN sed -i -e 's/^# deb-src/deb-src/' /etc/apt/sources.list
RUN rm -f /etc/apt/apt.conf.d/docker-clean

#ADD http://ftp.us.debian.org/debian/dists/unstable/Release apt_update_cachebust_sid
ADD http://archive.ubuntu.com/ubuntu/dists/lunar/Release apt_update_cachebust_lunar

RUN apt-get -y update \
    && apt-get -y install build-essential devscripts

RUN apt-get -y build-dep \
    libdrm \
    libwayland-server0 \
    wayland-protocols \
    libvulkan-dev \
    libsdl2-dev

# debian sid
RUN apt-key adv --keyserver keyserver.ubuntu.com \
        --recv-keys 1F89983E0081FDE018F3CC9673A4F27B8DD47936 \
    && apt-key adv --keyserver keyserver.ubuntu.com \
        --recv-keys AC530D520F2F3269F5E98313A48449044AAD5C5D
COPY apt /etc/apt/
RUN apt-get -y update \
    && dpkg --clear-avail \
    && sync-available
