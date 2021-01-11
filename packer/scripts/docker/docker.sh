#!/bin/bash 

set -ex

# Install Docker in rootless mode
# Source: https://docs.docker.com/engine/security/rootless/
sudo apt-get update -y
sudo apt-get install -y iptables uidmap

curl -fsSL https://get.docker.com/rootless | sh

# Start the daemon 
systemctl --user start docker

# Enable the daemon to launch on startup
systemctl --user enable docker
sudo loginctl enable-linger $(whoami)

export PATH=/home/ubuntu/bin:$PATH
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

# Ensure these variables are exported on reboot
echo "export PATH=/home/ubuntu/bin:$PATH" >> /home/ubuntu/.bashrc
echo "export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock" >> /home/ubuntu/.bashrc

# Check to ensure rootless is enabled
docker info | grep rootless
