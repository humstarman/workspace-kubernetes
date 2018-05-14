#!/bin/bash

set -e

if [ ! -x "$(command -v docker)" ]; then
  echo "$(date) - [EOOR] - no docker installed!"
  exit 1
fi

DOCKER=$(which docker)
NGINX_CONF_DIR=/etc/nginx
[ -d "$NGINX_CONF_DIR" ] || mkdir -p "$NGINX_CONF_DIR"
SYSTEMD_UNIT_DIR=/etc/systemd/system
#[ -d "$SYSTEMD_UNIT_DIR" ] || mkdir -p "$SYSTEMD_UNIT_DIR"

cat << EOF > $NGINX_CONF_DIR/nginx.conf
error_log stderr notice;

worker_processes auto;
events {
  multi_accept on;
  use epoll;
  worker_connections 1024;
}

stream {
    upstream kube_apiserver {
        least_conn;
        server 192.168.0.151:6443;
        server 192.168.0.152:6443;
        server 192.168.0.153:6443;
    }

    server {
        listen        0.0.0.0:6443;
        proxy_pass    kube_apiserver;
        proxy_timeout 10m;
        proxy_connect_timeout 1s;
    }
}
EOF

cat << EOF > $SYSTEMD_UNIT_DIR/nginx-proxy.service
[Unit]
Description=kubernetes apiserver docker wrapper
Wants=docker.socket
After=docker.service

[Service]
User=root
PermissionsStartOnly=true
ExecStart=$DOCKER run -p 6443:6443 \\
          -v $NGINX_CONF_DIR:/etc/nginx \\
          --name nginx-proxy \\
          --network host \\
          --restart on-failure:5 \\
          --memory 512M \\
          nginx:stable
ExecStartPre=-$DOCKER rm -f nginx-proxy
ExecStop=$DOCKER stop nginx-proxy
Restart=always
RestartSec=15s
TimeoutStartSec=30s

[Install]
WantedBy=multi-user.target
EOF

if false; then
  systemctl daemon-reload
  system enable nginx-proxy.service
  system restart nginx-proxy.service
fi
