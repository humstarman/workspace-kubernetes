#!/bin/bash

systemctl restart kube-apiserver kube-controller-manager kube-scheduler

# stop svc
systemctl restart kubelet docker

