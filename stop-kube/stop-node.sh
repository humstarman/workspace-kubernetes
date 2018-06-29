#!/bin/bash

# stop svc
systemctl stop kubelet kube-proxy flanneld docker

# clear files
# umount kubelet 挂载的目录
mount | grep '/var/lib/kubelet'| awk '{print $3}'|xargs sudo umount
# 删除 kubelet 工作目录
rm -rf /var/lib/kubelet
# clear iptables
iptables -F && iptables -X && iptables -F -t nat && iptables -X -t nat
