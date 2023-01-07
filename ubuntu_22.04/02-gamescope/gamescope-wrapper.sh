#!/bin/sh

PACKAGE_PATH="$( cd -- "$(dirname "$(realpath "$0" )" )" >/dev/null 2>&1 ; cd .. ; pwd -P )"

exec /usr/lib64/ld-linux-x86-64.so.2 \
    --library-path "${PACKAGE_PATH}/lib/x86_64-linux-gnu" \
    "${PACKAGE_PATH}/bin/gamescope.real" \
    "$@"
