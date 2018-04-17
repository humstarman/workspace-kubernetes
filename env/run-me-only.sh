#!/bin/bash

MASTER="172.31.78.215 172.31.78.216 172.31.78.217"
NET_ID="172.31.78"

mkdir -p ./tmp
BOOTSTRAP_TOKEN=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')
cp ./k8s.env ./tmp
sed -i "/^BOOTSTRAP_TOKEN=\"/ c BOOTSTRAP_TOKEN=\"${BOOTSTRAP_TOKEN}\"" ./tmp/k8s.env

ansible all -m shell -a "mkdir -p /var/env"
ansible all -m copy -a "src=./tmp/k8s.env dest=/var/env"

# token
ansible all -m shell -a "mkdir -p /etc/kubernetes"
echo -n -e "${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,\"system:kubelet-bootstrap\"" > ./tmp/token.csv
ansible all -m copy -a "src=./tmp/token.csv dest=/etc/kubernetes"


ansible master -m script -a "./put-this-ip.sh $NET_ID"
#ansible node -m script -a "./put-node-ip.sh $NET_ID"

NAME=etcd

IPS=$MASTER

N=$(echo $MASTER | wc | awk -F ' ' '{print $2}')

NODE_IPS=""
ETCD_NODES=""
ETCD_ENDPOINTS=""

for i in $(seq -s ' ' 1 $N); do
  NODE_NAME="${NAME}-${i}"
  IP=$(echo $IPS | awk -v j=$i -F ' ' '{print $j}')
  NODE_IPS+=" $IP"
  ETCD_NODES+=",${NODE_NAME}=https://$IP:2380"
  ETCD_ENDPOINTS+=",https://$IP:2379"
done

#echo $NODE_IPS
#echo $ETCD_NODES
NODE_IPS=${NODE_IPS#* }
ETCD_NODES=${ETCD_NODES#*,}
ETCD_ENDPOINTS=${ETCD_ENDPOINTS#*,}
#echo $NODE_IPS
#echo $ETCD_NODES

for i in $(seq -s ' ' 1 $N); do
  FILE="./tmp/etcd.env.${i}"
  [ -e $FILE ] && rm -f $FILE
  [ -e $FILE ] || touch $FILE
  NODE_NAME="${NAME}-${i}"
  IP=$(echo $IPS | awk -v j=$i -F ' ' '{print $j}')
  echo "export NODE_NAME=$NODE_NAME" > $FILE
  echo -e "export NODE_IPS=\"$NODE_IPS\"" >> $FILE
  echo "export ETCD_NODES=$ETCD_NODES" >> $FILE
  echo "export ETCD_ENDPOINTS=$ETCD_ENDPOINTS" >> $FILE
  ansible $IP -m copy -a "src=$FILE dest=/var/env/etcd.env"
done
rm -rf ./tmp

ansible all -m script -a ./mk-env-conf.sh

ansible all -m copy -a "src=./write-to-etc_profile dest=/tmp"
#IF=$(cat /etc/profile | grep 'FILES=$(find \/var\/env -name "\*.env"')
ansible all -m script -a ./deal-env.sh
#fi
#ansible all -m shell -a "rm -f /tmp/write-to-etc_profile"
