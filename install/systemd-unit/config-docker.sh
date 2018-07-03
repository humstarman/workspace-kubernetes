#!/bin/bash

iptables -P FORWARD ACCEPT
iptables -F && iptables -X && iptables -F -t nat && iptables -X -t nat
# mk docker-iptables.service
#cp docker-iptables.service /etc/systemd/system
cat > /etc/systemd/system/docker-iptables.service << EOF
[Unit]
Description=Make Iptables Rules for Docker

[Service]
Type=oneshot
ExecStart=/bin/sh \\
          -c \\
          "sleep 60 && /sbin/iptables -P FORWARD ACCEPT"

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/docker/daemon.json << EOF
{
  "data-root": "/opt/docker",
  "registry-mirror" : [
    "https://docker.mirrors.ustc.edu.cn",
    "hub-mirror.c.163.com"
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

systemctl enable docker-iptables.service
