#!/bin/bash

if false; then
if [[ ! "$(cat /etc/hosts | grep 'node-' | wc | awk -F ' ' '{print $1}')" > 1 ]]; then
  cat >> /etc/hosts << EOF 
172.31.78.215 node-215
172.31.78.216 node-216
172.31.78.217 node-217
EOF
fi
fi

cat >> /etc/hosts << EOF
192.168.100.151 node-151
192.168.100.152 node-152
192.168.100.153 node-153
192.168.100.154 node-154
192.168.100.161 node-161
192.168.100.162 node-162
192.168.100.163 node-163
192.168.100.164 node-164
192.168.100.165 node-165
192.168.100.166 node-166
EOF
