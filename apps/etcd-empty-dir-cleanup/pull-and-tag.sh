#!/bin/sh

set -e

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
DOCKER_HUB="lowyard"

GO_IMAGES="k8s.gcr.io/etcd-empty-dir-cleanup:3.1.12.0"

for GO_IMAGE in $GO_IMAGES; do
  NAME=${GO_IMAGE##*/}
  #echo $NAME
  PULLABLE=${DOCKER_HUB}/$NAME 
  REPOSITORY=${PULLABLE%%:*}
  TAG=${PULLABLE##*:}
  [ -z "$TAG" ] && TAG="latest"
  if [ -n "$(docker images | grep $REPOSITORY | grep $TAG)" ]; then
    echo "$(date) - [WARN] - $IMAGE already existed."
  else
    docker pull $PULLABLE
    echo "$(date) - [INFO] - image $PULLABLE pulled."
  fi
  docker tag $PULLABLE ${LOCAL_REPO}/$NAME
  echo "$(date) - [INFO] - rename $PULLABLE as ${LOCAL_REPO}/$NAME."
  docker push ${LOCAL_REPO}/$NAME
  echo "$(date) - [INFO] - image ${LOCAL_REPO}/$NAME pushed."
  ansible all -m shell -a "docker pull ${LOCAL_REPO}/$NAME"
  echo "$(date) - [INFO] - image ${LOCAL_REPO}/$NAME pulled at all nodes."
  ansible all -m shell -a "docker tag ${LOCAL_REPO}/$NAME $GO_IMAGE"
  echo "$(date) - [INFO] - rename image ${LOCAL_REPO}/$NAME as ${GO_IMAGE} at all nodes."
  ansible all -m shell -a "docker rmi ${LOCAL_REPO}/$NAME"
  echo "$(date) - [INFO] - delete temporary image ${LOCAL_REPO}/$NAME at all nodes."
done
