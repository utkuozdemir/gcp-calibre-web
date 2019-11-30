#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
set -x

DOMAIN_NAME=$1
ADMIN_EMAIL=$2
USE_TEST_CERT=$3
TIMEZONE=$4

check_run_as_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
  fi
}

set_timezone() {
  # shellcheck disable=SC2086
  ln -f -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime
  dpkg-reconfigure -f noninteractive tzdata
}

move_files_to_their_places() {
  mkdir -p /etc/nginx/snippets/
  mkdir -p /etc/nginx/sites-available/
  cp -f /tmp/files/reload-nginx-cron.sh /etc/cron.daily/reload-nginx
  cp -f /tmp/files/ssl-params.conf /etc/nginx/snippets/ssl-params.conf
  cp -f /tmp/files/calibre-web-proxy-initial.conf /etc/nginx/sites-available/calibre-web-proxy-initial.conf
  cp -f /tmp/files/calibre-web-proxy-final.conf /etc/nginx/sites-available/calibre-web-proxy-final.conf
  cp -f /tmp/files/docker-compose.yaml /home/ubuntu/docker-compose.yaml
  chmod 755 /etc/cron.daily/reload-nginx
}

install_packages() {
  apt-get update
  add-apt-repository -y ppa:certbot/certbot
  apt-get update
  apt-get install -y docker.io docker-compose haveged nginx certbot libatomic1 tzdata
  systemctl enable --now nginx
}

configure_nginx_initial() {
  rm -rf /etc/nginx/sites-enabled/default
  if [ ! -f /etc/nginx/dhparam.pem ]; then
    openssl dhparam -dsaparam -out /etc/nginx/dhparam.pem 4096
  fi

  ln -f -s /etc/nginx/sites-available/calibre-web-proxy-initial.conf /etc/nginx/sites-enabled/calibre-web-proxy-initial.conf
  systemctl reload nginx
}

configure_certbot() {
  mkdir -p /usr/share/nginx/html

  if [ "$USE_TEST_CERT" = true ]; then
    certbot certonly --test-cert --webroot --non-interactive --agree-tos -m "${ADMIN_EMAIL}" -w /usr/share/nginx/html -d "${DOMAIN_NAME}"
  else
    certbot certonly --webroot --non-interactive --agree-tos -m "${ADMIN_EMAIL}" -w /usr/share/nginx/html -d "${DOMAIN_NAME}"
  fi

  systemctl enable --now certbot.timer
}

configure_nginx_final() {
  rm -rf /etc/nginx/sites-enabled/calibre-web-proxy-initial.conf
  ln -f -s /etc/nginx/sites-available/calibre-web-proxy-final.conf /etc/nginx/sites-enabled/calibre-web-proxy-final.conf
  systemctl reload nginx
}

prepare_user() {
  adduser ubuntu docker
  mkdir -p /home/ubuntu/config
  mkdir -p /home/ubuntu/books
  chown -R ubuntu:ubuntu /home/ubuntu
}

start_containers() {
  su ubuntu -c "mkdir -p /home/ubuntu/books"
  docker-compose -f /home/ubuntu/docker-compose.yaml up -d
}

check_run_as_root
move_files_to_their_places
install_packages
set_timezone
configure_nginx_initial
configure_certbot
configure_nginx_final
start_containers
