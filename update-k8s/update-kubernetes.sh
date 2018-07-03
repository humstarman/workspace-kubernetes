#!/bin/bash
# stop svc
ansible master -m shell -a "systemctl stop kube-apiserver kube-controller-manager kube-scheduler"
ansible all -m shell -a "systemctl stop kubelet kube-proxy"
# master
BIN=kube-master-bin
mkdir -p kubernetes/server/bin/$BIN
cd kubernetes/server/bin && \
  mv kube-apiserver $BIN && \
  mv kube-controller-manager $BIN && \
  mv kube-scheduler $BIN && \
  cd -
echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [INFO] - distribute Kubernetes master components ... "
ansible master -m copy -a "src=./kubernetes/server/bin/$BIN/ dest=/usr/local/bin mode='a+x'"
# node
BIN=kube-node-bin
mkdir -p kubernetes/server/bin/$BIN
cd kubernetes/server/bin && \
  mv kubelet $BIN && \
  mv kube-proxy $BIN && \
  mv kubectl $BIN && \
  cd -
echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [INFO] - distribute Kubernetes node components ... "
ansible all -m copy -a "src=./kubernetes/server/bin/$BIN/ dest=/usr/local/bin mode='a+x'"
# restart svc
ansible all -m shell -a "systemctl daemon-reload"
ansible master -m shell -a "systemctl restart kube-apiserver kube-controller-manager kube-scheduler"
ansible all -m shell -a "systemctl restart kubelet kube-proxy"
