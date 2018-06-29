#!/bin/bash

if [ ! -x "$(command -v ansible)" ]; then
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - no ansible installed!"
  sleep 3
  exit 1
fi
ansible all -m script -a ./stop-node.sh
ansible master -m script -a ./stop-master.sh
