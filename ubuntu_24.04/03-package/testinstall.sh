#!/bin/sh

set -ex

LATEST_DEB=$(find . -name 'gamescope_*.deb' | sort -V -r | head -n 1)
apt install -y "$LATEST_DEB"
gamescope --help
