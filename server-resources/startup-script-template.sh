#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
set -x

apt-get update
apt-get install -y docker.io docker-compose haveged libatomic1 tzdata

adduser ubuntu docker
mkdir -p /home/ubuntu/config
mkdir -p /home/ubuntu/books

cat > /home/ubuntu/calibre-web.subfolder.conf <<EOL
location /calibre-web {
    return 301 \$scheme://\$host/calibre-web/;
}
location ^~ /calibre-web/ {
    resolver 127.0.0.11 valid=30s;
    set \$upstream_calibre_web calibre-web;
    proxy_pass http://\$upstream_calibre_web:8083;
    proxy_set_header Host \$http_host;
    proxy_set_header X-Scheme \$scheme;
    proxy_set_header X-Script-Name /calibre-web;
}
EOL

cat > /home/ubuntu/docker-compose.yaml <<EOL
version: "3"
services:
  letsencrypt:
    image: linuxserver/letsencrypt:amd64-1.0.0-ls79
    container_name: letsencrypt
    cap_add:
      - NET_ADMIN
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${timezone}
      - URL=${domain_name}
      - VALIDATION=http
      - EMAIL=${admin_email}
      - DHLEVEL=1024
      - ONLY_SUBDOMAINS=false
      - STAGING=${use_test_cert}
    volumes:
      - /home/ubuntu/calibre-web.subfolder.conf:/config/nginx/proxy-confs/calibre-web.subfolder.conf
    ports:
      - 443:443
      - 80:80 #optional
    restart: unless-stopped
  calibre-web:
    image: linuxserver/calibre-web:0.6.4-ls40
    container_name: calibre-web
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=${timezone}
      - DOCKER_MODS=linuxserver/calibre-web:calibre
    volumes:
      - /home/ubuntu/config:/config
      - /home/ubuntu/books:/books
    ports:
      - 8083:8083
    restart: unless-stopped
EOL

chown -R ubuntu:ubuntu /home/ubuntu
sudo -u ubuntu docker-compose -f /home/ubuntu/docker-compose.yaml up -d
