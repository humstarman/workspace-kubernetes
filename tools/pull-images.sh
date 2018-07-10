#!/bin/bash
show_help () {
cat << USAGE
usage: $0 [ -d DOCKER-IMAGE(S) ] [ -i LOCAL-DOCKER-REGISTRY-IP ] [ -p LOCAL-DOCKER-REGISTRY-PROT ]
    -d : Specify the image(s) to pull. If multiple, set the images in term of csv, 
         as 'image-1,image-2,image-3'.
    -i : Specify the IP address of local docker registry. 
    -p : Specify the port used by local docker registry. If not specified, use '5000' by default.
    -g : Specify the group used by ansible. If not specified, use 'all' by default.
USAGE
exit 0
}
[ -z "$*" ] && show_help
# Get Opts
while getopts "hd:i:p:g:" opt; do # 选项后面的冒号表示该选项需要参数
    case "$opt" in
    h)  show_help
        ;;
    d)  IMAGES=$OPTARG # 参数存在$OPTARG中
        ;;
    i)  LOCAL_REGISTRY_IP=$OPTARG
        ;;
    p)  LOCAL_REGISTRY_PORT=$OPTARG
        ;;
    g)  GROUP=$OPTARG
        ;;
    ?)  # 当有不认识的选项的时候arg为?
        echo "unkonw argument"
        exit 1
        ;;
    esac
done
chk_var () {
if [ -z "$2" ]; then
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - no input for \"$1\", try \"$0 -h\"."
  sleep 3
  exit 1
fi
}
chk_var -d $IMAGES
chk_var -i $LOCAL_REGISTRY_IP 
chk_install () {
if [ ! -x "$(command -v $1)" ]; then
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - no $1 installed !!!"
  sleep 3
  exit 1
fi
}
NEEDS="docker ansible"
for NEED in $NEEDS; do
  chk_install $NEED
done
IMAGES=$(echo $IMAGES | tr "," " ")
[ -z "$LOCAL_REGISTRY_PORT" ] && LOCAL_REGISTRY_PORT="5000"
[ -z "$GROUP" ] && GROUP="all"
LOCAL_REGISTRY="${LOCAL_REGISTRY_IP}:${LOCAL_REGISTRY_PORT}"
pull_distribute_tag () {
  IMAGE=$1
  NAME=${IMAGE%%:*}
  TAG=${IMAGE##*:}
  [ -z "$TAG" ] && TAG="latest"
  #echo $NAME
  #echo $TAG
  if [ -n "$(docker images | grep $NAME | grep $TAG)" ]; then
    echo "$(date) - [WARN] - $IMAGE already existed."
  else
    docker pull $IMAGE 
    echo "$(date) - [INFO] - image $IMAGE pulled."
  fi
  NAME=${IMAGE##*/}
  docker tag $IMAGE ${LOCAL_REGISTRY}/$NAME
  echo "$(date) - [INFO] - rename $IMAGE as ${LOCAL_REGISTRY}/$NAME."
  docker push ${LOCAL_REGISTRY}/$NAME
  echo "$(date) - [INFO] - image ${LOCAL_REGISTRY}/$NAME pushed."
  ansible $GROUP -m shell -a "docker pull ${LOCAL_REGISTRY}/$NAME"
  echo "$(date) - [INFO] - image ${LOCAL_REGISTRY}/$NAME pulled at all nodes."
  ansible $GROUP -m shell -a "docker tag ${LOCAL_REGISTRY}/$NAME $IMAGE"
  echo "$(date) - [INFO] - rename image ${LOCAL_REGISTRY}/$NAME as ${IMAGE} at all nodes."
  ansible $GROUP -m shell -a "docker rmi ${LOCAL_REGISTRY}/$NAME"
  echo "$(date) - [INFO] - delete temporary image ${LOCAL_REGISTRY}/$NAME at all nodes."
}
for IMAGE in $IMAGES; do
  pull_distribute_tag $IMAGE
done
