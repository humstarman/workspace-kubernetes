#!/bin/bash
APPS=$(yum list installed | grep gluster | awk -F ' ' '{print $1}')
if [[ -z ${APPS} ]]; then
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [INFO] - No installed found."
  exit 0
fi
for APP in $APPS; do
  APP=${APP%%.*}
  yum remove -y $APP
done
echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [INFO] - List installed:"
cat <<EOF
$(yum list installed | grep gluster | awk -F ' ' '{print $1}')
EOF
