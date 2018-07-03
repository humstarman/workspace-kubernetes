#!/bin/bash
if [ -x "$(command -v yum)" ]; then
  yum install -y bash-completion
else 
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - wrong type of distribution !!!"
  sleep 3
  exit 1
fi
