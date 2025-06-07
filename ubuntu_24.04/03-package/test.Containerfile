FROM docker.io/ubuntu:24.04

RUN rm -f /etc/apt/apt.conf.d/docker-clean
RUN apt-get -y update
