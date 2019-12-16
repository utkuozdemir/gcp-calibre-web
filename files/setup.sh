#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
set -x

install_packages() {
  sudo apt-get update
  sudo apt-get install -y docker.io docker-compose haveged libatomic1 tzdata
}

prepare_user() {
  sudo adduser ubuntu docker
  mkdir -p /home/ubuntu/config
  mkdir -p /home/ubuntu/books
}

start_containers() {
  su ubuntu -c "mkdir -p /home/ubuntu/books"
  docker-compose -f /home/ubuntu/docker-compose.yaml up -d
}

install_packages
prepare_user
start_containers
