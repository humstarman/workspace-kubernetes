#!/bin/bash

kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
IP=$(kubectl get -n kube-system svc tiller-deploy --template="{{ .spec.clusterIP }}")
PORT=$(kubectl get -n kube-system svc tiller-deploy --template="{{ (index .spec.ports 0).port }}")
#kubectl get -n kube-system svc tiller-deploy -o jsonpath="{.spec.clusterIP}"
#kubectl get -n kube-system svc tiller-deploy -o jsonpath="{.spec.ports[0].port}"

HELM_HOST="$IP:$PORT"

if [ -z "$(cat /etc/profile | grep 'export HELM_HOST=')" ]; then
  echo "export HELM_HOST=$HELM_HOST" >> /etc/profile
else
  if [ "$(cat /etc/profile | grep 'export HELM_HOST=')" != "export HELM_HOST=$HELM_HOST" ]; then
    sed -i '/export HELM_HOST=/d' /etc/profile && echo "export HELM_HOST=$HELM_HOST" >> /etc/profile 
  fi
fi
