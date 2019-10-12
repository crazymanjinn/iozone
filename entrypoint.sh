#!/bin/sh
set -eu

[ -z ${DEBUG:+x} ] || set -x

useradd -M -u ${USERID:-9001} -s /sbin/nologin iozone

mkdir -p "${DATA_DIR:-/data}"
chown -R iozone:iozone "${DATA_DIR:-/data}"

exec su-exec iozone:iozone "$@"
