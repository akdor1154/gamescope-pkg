FROM docker.io/ubuntu:22.04

RUN sed -i -e 's/^# deb-src/deb-src/' /etc/apt/sources.list
RUN rm -f /etc/apt/apt.conf.d/docker-clean

ADD http://archive.ubuntu.com/ubuntu/dists/jammy-updates/Release apt_update_cachebust

RUN apt-get -y update \
    && apt-get -y install build-essential devscripts

RUN apt-get -y install meson ninja-build pkg-config cmake

RUN apt-get -y install \
    libx11-dev \
    libxcb1-dev \
    libx11-xcb-dev \
    libxdamage-dev \
    libxcomposite-dev \
    libxrender-dev \
    libxext-dev \
    libxfixes-dev \
    libxxf86vm-dev \
    libxtst-dev \
    libxres-dev \
    libxkbcommon-dev \
    libcap-dev \
    libpipewire-0.3-dev \
    glslang-tools \
    libpixman-1-dev \
    libinput-dev \
    libseat-dev \
    libsystemd-dev \
    libxcb-composite0-dev \
    xwayland

RUN apt-get -y install \
    libxcb-icccm4-dev \
    libxcb-res0-dev \
    libxmu-dev \
    libglm-dev \
    libbenchmark-dev \
    libsamplerate0-dev \
    libxcursor-dev \
    libxrandr-dev \
    libxss-dev \
    libdecor-0-dev
