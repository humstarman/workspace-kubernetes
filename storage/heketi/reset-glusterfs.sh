#!/bin/bash
VGS=$(lsblk | grep vg | awk -F '─' '{print $2}' | awk -F ' ' '{print $1}' )
if [[ -z $VGS ]]; then
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [INFO] - no VG found."
  exit 0
fi
TMP=$(mktemp /tmp/tmp.XXX)
echo $VGS > $TMP
sed -i s?" "?"\n"?g $TMP
VGS=$(tac $TMP)
for VG in $VGS; do
  dmsetup remove -f $VG
done
lsblk
