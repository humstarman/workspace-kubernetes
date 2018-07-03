#!/bin/bash
BIN=/usr/local/bin
# stop svc
systemctl stop kube-apiserver kube-controller-manager kube-scheduler
systemctl stop kubelet kube-proxy
# master
cd kubernetes/server/bin && \
  cp kube-apiserver $BIN && \
  cp kube-controller-manager $BIN && \
  cp kube-scheduler $BIN && \
  cd -
# node
mkdir -p kubernetes/server/bin/$BIN
cd kubernetes/server/bin && \
  cp kubelet $BIN && \
  cp kube-proxy $BIN && \
  cp kubectl $BIN && \
  cd -
# restart svc
systemctl daemon-reload
systemctl restart kube-apiserver kube-controller-manager kube-scheduler
systemctl restart kubelet kube-proxy
