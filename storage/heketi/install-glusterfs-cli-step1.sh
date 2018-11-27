#!/bin/bash
GlusterVer=3.12
# install glusterfs
if [ -x "$(command -v yum)" ]; then
  yum makecache fast
  yum install centos-release-gluster -y
  yum install -y glusterfs-client
elif [ -x "$(command -v apt-get)" ]; then
  add-apt-repository -y ppa:gluster/glusterfs-$GlusterVer
  apt-get update
  apt install -y glusterfs-client
else
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - unknown Distributor ID."
  exit 1
fi

