#!/bin/bash

MASTERS=$@

if [ -z "$MASTERS" ]; then
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - need masters input!"
  exit 1
fi
if [ ! -x "$(command -v ansible)" ]; then
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - no ansible installed!"
  exit 1
fi

echo $MASTERS
for MASTER in $MASTERS; do
  ansible $MASTER -m shell -a "echo 'hello world'"
done
