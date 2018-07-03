#!/bin/bash

if [ ! -x "$(command -v kubectl)" ]; then
  echo "$(date) - [ERROR] - no kubectl installed!"
  exit 1
fi
kubectl apply -f ./manifest/.

if false; then
SA="spark"
CR="edit"
CRB="spark-role"
NS="default"
if [ -z "$(kubectl get serviceaccount | grep $SA)" ]; then
  kubectl create serviceaccount $SA 
else
  echo "$(date) - [WARN] serviceAccount $SA existed."
fi
if [ -z "$(kubectl get clusterrolebinding | grep $CRB)" ]; then
  kubectl create clusterrolebinding $CRB --clusterrole=$CR --serviceaccount=$NS:$SA --namespace=$SA
else
  echo "$(date) - [WARN] clusterrolebinding $CRB existed."
fi
fi
