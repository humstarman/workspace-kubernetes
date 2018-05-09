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
DOCKER_HUB="lowyard"

GO_IMAGES="k8s.gcr.io/hyperkube:v1.0.7 \
gcr.io/kubeflow-images-public/tf-model-server-http-proxy:v20180327-995786ec \
gcr.io/kubeflow-images-public/tf-model-server-cpu:v20180327-995786ec \
gcr.io/kubeflow-images-public/tf-model-server-gpu:v20180327-995786ec \
gcr.io/kubeflow/tf-benchmarks-cpu:v20171202-bdab599-dirty-284af3 \
gcr.io/kubeflow/tf-benchmarks-gpu:v20171202-bdab599-dirty-284af3 \
gcr.io/cloud-solutions-group/esp-sample-app:1.0.0 \
gcr.io/google_containers/spartakus-amd64:v1.0.0 \
gcr.io/kubeflow-images-public/envoy:v20180309-0fb4886b463698702b6a08955045731903a18738 \
gcr.io/kubeflow-images-public/tf_operator:v20180329-a7511ff \
gcr.io/kubeflow/jupyterhub-k8s:1.0.1 \
gcr.io/kubeflow-images-public/tf_operator:v20180226-403 \
gcr.io/kubeflow-images-public/tensorflow-1.4.1-notebook-cpu:v20180419-0ad94c4e \
gcr.io/kubeflow/tensorflow-notebook-cpu"

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
