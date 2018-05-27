#!/bin/bash

if [[ ! "$(cat /etc/hosts | grep 'node-' | wc | awk -F ' ' '{print $1}')" > 1 ]]; then
  cat >> /etc/hosts << EOF 
172.31.78.215 node-215
172.31.78.216 node-216
172.31.78.217 node-217
EOF
fi
