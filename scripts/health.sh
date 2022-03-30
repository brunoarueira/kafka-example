#!/usr/bin/env sh

set -ex

while ! echo srvr | nc -vz zookeeper 2181 > /dev/null; do echo 'waiting for zookeeper'; sleep 3; done;

$*
