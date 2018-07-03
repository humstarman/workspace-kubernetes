#!/bin/bash
GROUP=${1:-glusterfs}
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
