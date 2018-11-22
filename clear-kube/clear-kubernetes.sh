#!/bin/bash

show_help () {
cat << USAGE
usage: $0 [ -m ANSIBLE-GROUP-OF-MASTER ] [ -n ANSIBLE-GROUP-OF-NODE ]
    -m : Specify the ansible group of Kubernetes Masters.
         If not specificed, the group would be the same as -n.
    -n : Specify the ansible group of Kubernetes Nodes. 
USAGE
exit 0
}

# Get Opts
while getopts "hm:n:" opt; do # 选项后面的冒号表示该选项需要参数
    case "$opt" in
    h)  show_help
        ;;
    m)  MASTER=$OPTARG
        ;;
    n)  NODE=$OPTARG
        ;;
    ?)  # 当有不认识的选项的时候arg为?
        echo "unkonw argument"
        exit 1
        ;;
    esac
done

[[ -z $* ]] && show_help

chk_var () {
if [ -z "$2" ]; then
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - no input for \"$1\", try \"$0 -h\"."
  sleep 3
  exit 1
fi
}
chk_var -n $NODE
[[ -z $MASTER ]] && MASTER=${NODE}

chk_install () {
if [ ! -x "$(command -v $1)" ]; then
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - no $1 installed !!!"
  sleep 3
  exit 1
fi
}
NEEDS="ansible"
for NEED in $NEEDS; do
  chk_install $NEED
done

echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [INFO] - master: $(echo ${MASTER})"
echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [INFO] - node: $(echo ${NODE})"

ansible ${NODE} -m script -a ./clear-node.sh
ansible ${MASTER} -m script -a ./clear-master.sh
ansible ${MASTER} -m script -a ./clear-etcd.sh
