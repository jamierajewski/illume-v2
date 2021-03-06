#!/bin/bash 

set -ex

# Common across all nodes
export GOVERSION=1.16.4

# Dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common \
     wget git python nfs-common ceph-common cgroup-tools

# Configure SSH daemon
sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin no\n/g' /etc/ssh/sshd_config
sudo sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no\n/g' /etc/ssh/sshd_config
sudo sed -i 's/^ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no\n/g' /etc/ssh/sshd_config
sudo sed -i 's/^GSSAPIAuthentication.*/GSSAPIAuthentication no\n/g' /etc/ssh/sshd_config
sudo sed -i 's/^#TCPKeepAlive.*/TCPKeepAlive yes\n/g' /etc/ssh/sshd_config
echo "ClientAliveInterval 10" | sudo tee -a /etc/ssh/sshd_config

# Install golang, used to compile Singularity among other things
wget https://golang.org/dl/go${GOVERSION}.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go${GOVERSION}.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/custom.sh > /dev/null
source /etc/profile.d/custom.sh
# Verify it works
go version
rm -f go${GOVERSION}.linux-amd64.tar.gz

# Enable rpc service
sudo systemctl add-wants multi-user.target rpc-statd.service

# Install unattended-upgrades to automatically install security patches daily
sudo apt-get install unattended-upgrades

sudo reboot