#!/bin/bash
ansible all -m shell -a "systemctl stop kube-proxy"
