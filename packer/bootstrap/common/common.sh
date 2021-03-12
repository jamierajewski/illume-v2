#!/bin/bash 

set -ex

# Common across all nodes

# Dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common \
     wget git python nfs-common ceph-common

# Configure SSH daemon
sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin no\n/g' /etc/ssh/sshd_config
sudo sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no\n/g' /etc/ssh/sshd_config
sudo sed -i 's/^ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no\n/g' /etc/ssh/sshd_config
sudo sed -i 's/^GSSAPIAuthentication.*/GSSAPIAuthentication no\n/g' /etc/ssh/sshd_config

# Create system-wide profile override for custom additions
echo "#!/bin/bash" | sudo tee /etc/profile.d/custom.sh > /dev/null
# Alias for safe rm
echo 'alias rm="rm -i"' | sudo tee -a /etc/profile.d/custom.sh > /dev/null
sudo chmod +x /etc/profile.d/custom.sh

# Install golang, used to compile Singularity among other things
wget https://golang.org/dl/go1.15.7.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.15.7.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/profile.d/custom.sh > /dev/null
source /etc/profile.d/custom.sh
# Verify it works
go version
rm -f go1.15.7.linux-amd64.tar.gz

# Enable rpc service
sudo systemctl add-wants multi-user.target rpc-statd.service

sudo reboot