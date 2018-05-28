#!/bin/bash

GlusterVer=3.12
VOL_FOR_GLUSTER="opt"

# mk switch-on-kernel-modules.sh
cat > /usr/local/bin/switch-on-kernel-modules.sh << EOF
#!/bin/bash
MODULES="dm_snapshot dm_mirror dm_thin_pool"
for MODULE in \$MODULES; do
  modprobe \$MODULE
done
for MODULE in \$MODULES; do
  lsmod | grep \$MODULE
done
iptables -I INPUT -p tcp --dport 24007 -j ACCEPT
EOF
chmod +x /usr/local/bin/switch-on-kernel-modules.sh
# mk mod-for-glusterfs.service 
cat > /etc/systemd/system/mod-for-glusterfs.service << EOF
[Unit]
Description=Switch-on Kernel Modules Needed by Glusterfs

[Service]
Type=oneshot
ExecStart=/usr/local/bin/switch-on-kernel-modules.sh

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable mod-for-glusterfs.service
systemctl restart mod-for-glusterfs.service

# install glusterfs
if [ -x "$(command -v yum)" ]; then
  yum install centos-release-gluster -y
  yum install -y glusterfs glusterfs-server glusterfs-fuse glusterfs-rdma glusterfs-geo-replication glusterfs-devel
elif [ -x "$(command -v apt-get)" ]; then
  add-apt-repository -y ppa:gluster/glusterfs-$GlusterVer
  apt-get update
  apt install -y glusterfs-server glusterfs-client
else
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - unknown Distributor ID."
  exit 1
fi

#sed -i "s/var\/lib/$VOL_FOR_GLUSTER/g" /etc/glusterfs/glusterd.vol

iptables -I INPUT -p tcp --dport 24007 -j ACCEPT

mkdir -p /$VOL_FOR_GLUSTER/gfs_data

systemctl daemon-reload
systemctl enable glusterd
systemctl restart glusterd

cat >> /usr/local/bin/switch-on-kernel-modules.sh << EOF
sleep 10 && systemctl restart glusterd
EOF
# config /etc/hosts
if [[ ! "$(cat /etc/hosts | grep 'node-' | wc | awk -F ' ' '{print $1}')" > 1 ]]; then
  cat >> /etc/hosts << EOF
192.168.100.151 node-151
192.168.100.152 node-152
192.168.100.153 node-153
192.168.100.154 node-154
192.168.100.161 node-161
192.168.100.162 node-162
192.168.100.163 node-163
192.168.100.164 node-164
192.168.100.165 node-165
192.168.100.166 node-166
EOF
fi
