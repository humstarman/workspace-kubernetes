#!/bin/bash
NET_ID="192.168.100."
ID=$(hostname --all-ip-address)
ID=${ID#*${NET_ID}}
ID=${ID%% *}
IP=${NET_ID}$ID
HOSTNAME="node-${ID}"
cat > /etc/hostname << EOF
$HOSTNAME
EOF
hostnamectl set-hostname $HOSTNAME
