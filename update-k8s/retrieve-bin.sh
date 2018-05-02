#!/bin/bash

set -e

FROM=$1
if [ -z "$FROM" ]; then
  echo "$(date) - [ERROR] - need source file."
  exit 1
fi

TO=$2
if [ -z "$TO" ]; then
  TO="/opt/app/k8s-bin"
fi

[ -d "$TO" ] || mkdir -p "$TO"

COMPONENTS="kube-apiserver kube-controller-manager kube-scheduler kubelet kube-proxy kubectl"
for COMPONENT in $COMPONENTS; do
  cp $FROM/$COMPONENT $TO
done
