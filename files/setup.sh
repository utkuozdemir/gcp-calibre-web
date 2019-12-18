#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
set -x

sudo apt-get update
sudo apt-get install -y docker.io docker-compose haveged libatomic1 tzdata

sudo adduser ubuntu docker
mkdir -p /home/ubuntu/config
mkdir -p /home/ubuntu/books

