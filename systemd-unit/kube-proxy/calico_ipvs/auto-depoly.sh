#!/bin/bash
ansible all -m copy -a "src=kube-proxy.service dest=/etc/systemd/system"
ansible all -m shell -a "systemctl daemon-reload"
ansible all -m shell -a "systemctl restart kube-proxy"
