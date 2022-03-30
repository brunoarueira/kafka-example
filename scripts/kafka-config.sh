#!/bin/sh
set -ex

kafka-topics --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic analytics
