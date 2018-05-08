#!/bin/sh

if [ ! -x "$(command -v docker)" ]; then
  echo "$(date) - [ERROR] - no docker installed!"
  sleep 3
  exit 1
fi
if [ ! -x "$(command -v ansible)" ]; then
  echo "$(date) - [ERROR] - no ansible installed!"
  sleep 3
  exit 1
fi

LOCAL_REPO="172.31.78.217:5000"

IMAGES="kubespark/spark-driver:v2.2.0-kubernetes-0.5.0 \
kubespark/spark-executor:v2.2.0-kubernetes-0.5.0 \
kubespark/spark-init:v2.2.0-kubernetes-0.5.0 \
kubespark/spark-resource-staging-server:v2.2.0-kubernetes-0.5.0 \
kubespark/spark-driver-py:v2.2.0-kubernetes-0.5.0 \
kubespark/spark-executor-py:v2.2.0-kubernetes-0.5.0 \
kubespark/spark-driver-r:v2.2.0-kubernetes-0.5.0 \
kubespark/spark-executor-r:v2.2.0-kubernetes-0.5.0 \
kubespark/spark-resource-staging-server:v2.2.0-kubernetes-0.5.0 \
kubespark/spark-shuffle:v2.2.0-kubernetes-0.5.0"

function pull_distribute_tag() {
  IMAGE=$1
  docker pull $IMAGE 
  echo "$(date) - [INFO] - image $IMAGE pulled."
  NAME=${IMAGE##*/}
  docker tag $IMAGE ${LOCAL_REPO}/$NAME
  echo "$(date) - [INFO] - rename $IMAGE as ${LOCAL_REPO}/$NAME."
  docker push ${LOCAL_REPO}/$NAME
  echo "$(date) - [INFO] - image ${LOCAL_REPO}/$NAME pushed."
  ansible all -m shell -a "docker pull ${LOCAL_REPO}/$NAME"
  echo "$(date) - [INFO] - image ${LOCAL_REPO}/$NAME pulled at all nodes."
  ansible all -m shell -a "docker tag ${LOCAL_REPO}/$NAME $IMAGE"
  echo "$(date) - [INFO] - rename image ${LOCAL_REPO}/$NAME as ${IMAGE} at all nodes."
  ansible all -m shell -a "docker rmi ${LOCAL_REPO}/$NAME"
  echo "$(date) - [INFO] - delete temporary image ${LOCAL_REPO}/$NAME at all nodes."
}

for IMAGE in $IMAGES; do
  NAME=${IMAGE%%:*}
  TAG=${IMAGE##*:}
  #echo $NAME
  #echo $TAG
  if [[ -n "$(docker images | grep $NAME)"  && -n "$(docker images | grep $TAG)" ]]; then
    echo "$(date) - [WARN] - $IMAGE already existed."
  else
    pull_distribute_tag $IMAGE
  fi
  while true; do
    pull_distribute_tag $IMAGE && break;
  done
done
