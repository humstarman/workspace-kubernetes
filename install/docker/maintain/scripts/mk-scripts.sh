#!/bin/bash
show_help () {
cat << USAGE
usage: $0 [ -g ANSIBLE-GROUP ]
    -g : Specify ansibe group to use. 
USAGE
exit 0
}
# Get Opts
while getopts "hg:" opt; do # 选项后面的冒号表示该选项需要参数
    case "$opt" in
    h)  show_help
        ;;
    g)  GROUP=$OPTARG # 参数存在$OPTARG中
        ;;
    ?)  # 当有不认识的选项的时候arg为?
        echo "unkonw argument"
        exit 1
        ;;
    esac
done
[ -z "$*" ] && show_help
chk_var () {
if [ -z "$2" ]; then
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - no input for \"$1\", try \"$0 -h\"."
  sleep 3
  exit 1
fi
}
chk_var -g $GROUP
FILE=del-untagged-images.sh
BIN=/usr/local/bin/${FILE}
cat > $BIN <<"EOF"
#!/bin/bash
set -e
if [ ! -x "$(command -v docker)" ]; then
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - $0 - [ERROR] - no docker installed."
  sleep 3
  exit 1
fi
if [ -z "$(docker images -f 'dangling=true' -q)" ]; then
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [WARN] - no 'none' tagged image."
  sleep 3
  exit 0
fi
docker rmi $(docker images -f "dangling=true" -q)
exit 0
EOF
chmod +x $BIN
CRON=/etc/crontab
if ! cat $CRON | grep "$BIN" >/dev/null 2>&1; then
  cat >> $CRON <<EOF 
2 2 * * * root ansible $GROUP -m script -a $BIN
EOF
fi
