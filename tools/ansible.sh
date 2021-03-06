#!/bin/bash
if [ -x "$(command -v apt-get)" ]; then
  apt-get install -y software-properties-common
  apt-add-repository -y ppa:ansible/ansible
  apt-get update
  apt-get install -y ansible
fi
if [ -x "$(command -v yum)" ]; then
  yum makecache
  yum install -y ansible
fi
