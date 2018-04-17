#!/bin/bash

# install -y conntrack
if [ -x "$(command -v yum)" ]; then
  yum install -y conntrack 
elif [ -x "$(command -v apt-get)" ]; then
  apt-get install -y conntrack
else
  echo "$(date) - $0 - [ERROR] - unknown Distributor ID."
  exit 1
fi
