#!/bin/sh

set -ex

apt install -y /pkg/gamescope_*.deb
gamescope --help
