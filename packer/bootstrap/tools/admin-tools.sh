#!/bin/bash

set -ex

sudo apt-get update
sudo apt-get install -y tmux emacs vim htop

# Install golang, used to build the Nvidia Prometheus exporter
wget https://golang.org/dl/go1.15.7.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.15.7.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/profile.d/custom.sh > /dev/null
source /etc/profile.d/custom.sh
# Verify it works
go version
rm -f go1.15.7.linux-amd64.tar.gz
