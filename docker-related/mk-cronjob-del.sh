#!/bin/bash

cat > /usr/local/bin/del-useless-images.sh << EOF
#!/bin/bash
set -e
if [ -x "\$(command -v docker)" ]; then
  if [ -n "\$(docker images | grep '<none>' | awk -F ' ' '{print \$3}')" ]; then
    docker images | grep '<none>' | awk -F ' ' '{print \$3}' | xargs docker rmi -f
  else
    echo "\$(date -d today +'%Y-%m-%d %H:%M:%S') - no 'none' tagged image."
  fi
else
  echo "\$(date -d today +'%Y-%m-%d %H:%M:%S') - [WARN] - no docker installed."
fi
EOF
chmod +x /usr/local/bin/del-useless-images.sh

cat > /usr/local/bin/del-exited-containers.sh << EOF
#!/bin/bash
set -e
if [ -x "\$(command -v docker)" ]; then
  if [ -n "\$(docker ps -a | grep Exited | awk -F ' ' '{print \$1}')" ]; then
    docker ps -a | grep Exited | awk -F ' ' '{print \$1}' | xargs docker rm -f
  else
    echo "\$(date -d today +'%Y-%m-%d %H:%M:%S') - no 'exited' tagged containers."
  fi
else
  echo "\$(date -d today +'%Y-%m-%d %H:%M:%S') - [WARN] - no docker installed."
fi
EOF
chmod +x /usr/local/bin/del-exited-containers.sh

CRON=/etc/creontab
if [ -z "$(cat $CRON | grep del-useless-images.sh)" ]; then
  cat >> $CRON << EOF
2 2 * * * root ansible all -m script -a /usr/local/bin/del-useless-images.sh
EOF
fi
if [ -z "$(cat $CRON | grep del-exited-containers.sh)" ]; then
  cat >> $CRON << EOF
22 2 * * * root ansible all -m script -a /usr/local/bin/del-exited-containers.sh
EOF
fi
