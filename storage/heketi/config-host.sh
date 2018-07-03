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
if $VIRTUAL_DISK; then
  IMG=/home/glusterfs.img
  DEV=/dev/loop0
  [ -f $IMG ] || dd if=/dev/zero of=${IMG} bs=1M count=$[100*1000] 
  losetup $DEV $IMG
  pvcreate -y $DEV
fi
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
