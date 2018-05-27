#!/bin/bash

if [ ! -x "$(command -v ansible)" ]; then
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - no ansible installed!"
  sleep 3
  exit 1
fi
ansible node -m script -a ./clear-node.sh
ansible master -m script -a ./clear-master.sh
ansible master -m script -a ./clear-etcd.sh
