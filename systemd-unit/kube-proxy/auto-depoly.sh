#!/bin/bash
DIR=$1
ansible all -m copy -a "src=${DIR}/kube-proxy.service dest=/etc/systemd/system"
ansible all -m shell -a "systemctl daemon-reload"
ansible all -m shell -a "systemctl enable kube-proxy"
ansible all -m shell -a "systemctl restart kube-proxy"
