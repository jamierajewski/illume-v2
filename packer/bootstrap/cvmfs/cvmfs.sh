#!/bin/bash 

set -ex

# Install CVMFS acording to official docs
wget https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest_all.deb
sudo dpkg -i cvmfs-release-latest_all.deb
sudo apt-get update -y
sudo apt-get install -y cvmfs
rm -f cvmfs-release-latest_all.deb

# Ensure AutoFS is working
sudo cvmfs_config setup

# The configuration will be done on deployment so that we can populate
# the proxy addresses
