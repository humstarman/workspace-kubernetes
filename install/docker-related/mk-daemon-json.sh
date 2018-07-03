#!/bin/bash

cat > /etc/docker/daemon.json << EOF
{
  "data-root": "/opt/docker",
  "registry-mirrors" : [
    "https://nmp34hlf.mirror.aliyuncs.com",
    "https://mirror.ccs.tencentyun.com"
  ],
  "insecure-registries" : [
    "192.168.0.0/16",
    "172.0.0.0/8",
    "10.0.0.0/8"
  ],
  "debug" : true,
  "experimental" : true,
  "max-concurrent-downloads" : 10
}
EOF

systemctl daemon-reload
systemctl enable docker
systemctl restart docker
