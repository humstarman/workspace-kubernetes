#!/bin/bash
set -e
DATA=/data/$(hostname -s)
mkdir -p $DATA
chown -R elasticsearch:elasticsearch /data
chown -R elasticsearch:elasticsearch $DATA
sed -i s^"/data"^"${DATA}"^g ./config/elasticsearch.yml
cat ./config/elasticsearch.yml
exit 0
