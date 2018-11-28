#!/bin/bash

show_help () {
cat << USAGE
usage: $0 [ -k ANSIBLE-GROUP-OF-ALL-THE-KUBERNETES-NODES ] [ -g ANSIBLE-GROUP-OF-GLUSTERFS-NODES ]
    -k : Specify the ansible group of all the Kubernetes nodes.
    -g : Specify the ansible group of Glusterfs nodes.
USAGE
exit 0
}

# Get Opts
while getopts "hk:g:" opt; do # 选项后面的冒号表示该选项需要参数
    case "$opt" in
    h)  show_help
        ;;
    k)  KUBERNETES=$OPTARG
        ;;
    g)  GLUSTERFS=$OPTARG
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
chk_var -k $KUBERNETES
chk_var -g $GLUSTERFS 

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

echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [INFO] - Kubernetes group: ${KUBERNETES}"
echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [INFO] - Glusterfs group: ${GLUSTERFS}"

# setp 1 
# install glusterfs cli
FILE=$(mktemp tmp.XXX)
cat > $FILE <<"EOF"
#!/bin/bash
GlusterVer=3.12
# install glusterfs
if [ -x "$(command -v yum)" ]; then
  yum makecache fast
  yum install centos-release-gluster -y
  yum install -y glusterfs-client
elif [ -x "$(command -v apt-get)" ]; then
  add-apt-repository -y ppa:gluster/glusterfs-$GlusterVer
  apt-get update
  apt install -y glusterfs-client
else
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - unknown Distributor ID."
  exit 1
fi
EOF
#ansible ${KUBERNETES} -m script -a ./${FILE}
#rm -f ./${FILE}

# step 2
# config host
FILE=$(mktemp tmp.XXX)
cat > $FILE <<"ENDOFFILE"
#!/bin/bash

# mk switch-on-kernel-modules.sh
NAME=mod-for-glusterfs
BIN=${NAME}.sh
SVC=${NAME}.service
cat > /usr/local/bin/${BIN} <<"EOF"
#!/bin/bash
VIRTUAL_DISK=true
MODULES="dm_snapshot dm_mirror dm_thin_pool"
for MODULE in $MODULES; do
  modprobe $MODULE
done
for MODULE in $MODULES; do
  lsmod | grep $MODULE
done
iptables -I INPUT -p tcp --dport 24007 -j ACCEPT
iptables -N heketi
iptables -A heketi -p tcp -m state --state NEW -m tcp --dport 24007 -j ACCEPT
iptables -A heketi -p tcp -m state --state NEW -m tcp --dport 24008 -j ACCEPT
iptables -A heketi -p tcp -m state --state NEW -m tcp --dport 2222 -j ACCEPT
iptables -A heketi -p tcp -m state --state NEW -m multiport --dports 49152:49251 -j ACCEPT
EOF
chmod +x /usr/local/bin/${BIN}
# mk mod-for-glusterfs.service
cat > /etc/systemd/system/${SVC} << EOF
[Unit]
Description=Switch-on Kernel Modules Needed by Glusterfs

[Service]
Type=oneshot
ExecStart=/usr/local/bin/${BIN}

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable $SVC
systemctl restart $SVC
ENDOFFILE
#ansible ${KUBERNETES} -m script -a ./${FILE}
#rm -f ./${FILE}

# step 3
# label the nodes
GROUP=${GLUSTERFS}
HOSTS=$(ansible $GROUP --list-hosts | sed /"hosts"/d)
LABEL="storagenode"
VAL="glusterfs"
for HOST in $HOSTS; do
  TMP=$(kubectl get node $HOST -o jsonpath={.metadata.labels.${LABEL}})
  if [[ "$TMP" != "$VAL" ]]; then
    if [ -z "$TMP" ]; then 
      kubectl label node $HOST ${LABEL}=${VAL}
    else
      kubectl label node $HOST ${LABEL}=${VAL} --overwrite
    fi
  fi
done
