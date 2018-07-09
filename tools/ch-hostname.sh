#!/bin/bash
show_help () {
cat << USAGE
usage: $0 [ -n NETWORK-ID ] [ -p HOSTNAME-PREFIX ]
    -n : Specify the net ID, 
    -p : Specify the hostname prefix. If not specified, use 'node-' by default.
USAGE
exit 0
}
[ -z "$*" ] && show_help
# Get Opts
while getopts "hn:p:" opt; do # 选项后面的冒号表示该选项需要参数
    case "$opt" in
    h)  show_help
        ;;
    n)  NET_ID=$OPTARG # 参数存在$OPTARG中
        ;;
    p)  PREFIX=$OPTARG
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
chk_var -n $NET_ID 
if ! hostname --all-ip-addresses </dev/null 2>&1 | grep $NET_ID >/dev/null 2>&1; then
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - no IP address ($(hostname --all-ip-addresses)) found in network: $NET_ID !!!"
  sleep 3
  exit 1
fi
[ -z "$PREFIX" ] && PREFIX="node-"
ID=$(hostname --all-ip-address)
ID=${ID#*${NET_ID}}
ID=${ID%% *}
IP=${NET_ID}$ID
HOSTNAME="${PREFIX}${IP}"
cat > /etc/hostname << EOF
$HOSTNAME
EOF
hostnamectl set-hostname $HOSTNAME
