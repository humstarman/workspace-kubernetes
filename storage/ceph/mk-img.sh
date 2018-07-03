#!/bin/bash

CEPH="ceph"
HOSTS=$(ansible $CEPH --list-hosts | sed /"hosts"/d)
FILE=/tmp/create-img.sh
IMG=/home/${CEPH}.img
DEV=/dev/loop0
cat > $FILE << EOF
#!/bin/bash
dd if=/dev/zero of=${IMG} bs=1M count=$[100*1000]
losetup $DEV $IMG
pvcreate -y $DEV 
EOF
