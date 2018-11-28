#!/bin/bash

show_help () {
cat << USAGE
usage: $0 [ -m ANSIBLE-GROUP-OF-KUBERNETES-MASTER ] [ -n ANSIBLE-GROUP-OF-KUBERNETES-NODE ]
    -m : Specify the ansible group of Kubernetes masters.
    -n : Specify the ansible group of Kubernetes nodes.
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
chk_var -m $MASTER
chk_var -n $NODE 

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

echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [INFO] - Kubernetes Master group: ${MASTER}"
echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [INFO] - Kubernetes Node group: ${NODE}"

# setp 1 
# stop node 
FILE=$(mktemp tmp.XXX)
cat > $FILE <<"EOF"
#!/bin/bash

# stop svc
systemctl stop kubelet kube-proxy flanneld docker

# clear files
# umount kubelet mounted path
mount | grep '/var/lib/kubelet'| awk '{print $3}'|xargs sudo umount
# remove kubelet workspace path
rm -rf /var/lib/kubelet
# clear iptables
iptables -F && iptables -X && iptables -F -t nat && iptables -X -t nat
EOF
#ansible ${NODE} -m script -a ./${FILE}
#rm -f ./${FILE}

# step 2 
# stop master
FILE=$(mktemp tmp.XXX)
cat > $FILE <<"EOF"
#!/bin/bash

# stop svc
systemctl stop kube-apiserver kube-controller-manager kube-scheduler
EOF
#ansible ${MASTER} -m script -a ./${FILE}
#rm -f ./${FILE}

# step 3 
# stop etcd 
FILE=$(mktemp tmp.XXX)
cat > $FILE <<"EOF"
#!/bin/bash

# stop svc
systemctl stop etcd

# clear files
# remove workspace path and data path of etcd
rm -rf /var/lib/etcd
# remove systemd unit file
rm -rf /etc/systemd/system/etcd.service
# remove binary file of etcd 
rm -rf /usr/local/bin/etcd
# remove TLS cert file
rm -rf /etc/etcd/ssl/*
EOF
#ansible ${MASTER} -m script -a ./${FILE}
#rm -f ./${FILE}
