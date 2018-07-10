#!/bin/bash

DS=busybox-ds

INFO=$(kubectl get po -o wide | grep $DS)
#echo $INFO
N=$(kubectl get po -o wide | grep $DS | wc -l)
#echo $N
for i in $(seq -s ' ' $[1+1] $[$N+1]); do
  GROUP=$(echo $INFO | awk -F "$DS" -v j=$i '{print $j}')
  #echo $GROUP
  POD=$(echo $GROUP | awk -F ' ' '{print $6}')
  HOST=$(echo $GROUP | awk -F ' ' '{print $7}')
  if ping -c 1 $POD >/dev/null 2>&1; then
    echo "$POD on $HOST is: good"
  else
    echo "$POD on $HOST is: NOT good"
  fi 
done
