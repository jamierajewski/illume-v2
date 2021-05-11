#!/bin/bash 

set -ex

# Common across all nodes
export GOVERSION=1.16.4

# Dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common \
     wget git python nfs-common ceph-common

# Configure SSH daemon
sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin no\n/g' /etc/ssh/sshd_config
sudo sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no\n/g' /etc/ssh/sshd_config
sudo sed -i 's/^ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no\n/g' /etc/ssh/sshd_config
sudo sed -i 's/^GSSAPIAuthentication.*/GSSAPIAuthentication no\n/g' /etc/ssh/sshd_config

# Add system-wide additions to bash.bashrc
# Alias for safe rm
echo 'alias rm="rm -i"' | sudo tee -a /etc/bash.bashrc > /dev/null

# Install golang, used to compile Singularity among other things
wget https://golang.org/dl/go${GOVERSION}.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go${GOVERSION}.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/bash.bashrc > /dev/null
source /etc/bash.bashrc
# Verify it works
go version
rm -f go${GOVERSION}.linux-amd64.tar.gz

# Enable rpc service
sudo systemctl add-wants multi-user.target rpc-statd.service

# Install unattended-upgrades to automatically install security patches daily
sudo apt-get install unattended-upgrades

sudo reboot