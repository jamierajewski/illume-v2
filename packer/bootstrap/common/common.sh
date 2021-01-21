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
sudo chmod +x /etc/profile.d/custom.sh

# Enable rpc service
sudo systemctl add-wants multi-user.target rpc-statd.service

sudo reboot