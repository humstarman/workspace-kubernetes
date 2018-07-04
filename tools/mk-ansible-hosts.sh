#!/bin/bash
show_help () {
cat << USAGE
usage: $0 [ -m MASTER-IP(S) ] [ -n NODE-IP(S) ] [ -a ANSIBLE-HOST-FILE ]
    -m : Specify the master IP(s), if multiple, set in term of csv. If not specified, find from file './master.csv' for default.
    -n : Specify the node IP(s), if multiple, set in term of csv. If not specified, find from file './node.csv' for default.
    -e : Specify the new node IP(s), if multiple, set in term of csv. If not specified, find from file './new.csv' for default.
    -a : Specify the ansible host file. If not specified, use '/etc/ansible/hosts' for default.
USAGE
exit 0
}
# Get Opts
while getopts "hn:p:" opt; do # 选项后面的冒号表示该选项需要参数
    case "$opt" in
    h)  show_help
        ;;
    m)  MASTERS=$OPTARG # 参数存在$OPTARG中
        ;;
    n)  NODES=$OPTARG
        ;;
    e)  NEW=$OPTARG
        ;;
    a)  ANSIBLE=$OPTARG
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
[ -z "$ANSIBLE" ] && ANSIBLE=/etc/ansible/hosts
