#!/bin/bash
FILE=del-untagged-images.sh
BIN=/usr/local/bin/${FILE}
rm -f $BIN
CRON=/etc/crontab
sed -i /"${FILE}"/d $CRON
