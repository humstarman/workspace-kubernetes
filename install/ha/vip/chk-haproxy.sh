#!/bin/bash

flag=$(systemctl status haproxy &> /dev/null;echo $?)

if [[ $flag != 0 ]];then
  echo "$(date -d today +"%Y-%m-%d %H:%M:%S") - [ERROR] - haproxy is down, close the keepalived"
  systemctl stop keepalived
fi
