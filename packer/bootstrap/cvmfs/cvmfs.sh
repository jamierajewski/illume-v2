#!/bin/bash 

set -ex

# Install CVMFS acording to official docs
wget https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest_all.deb
sudo dpkg -i cvmfs-release-latest_all.deb
# Install dependencies for sft.cern.ch repo
wget https://gitlab.cern.ch/linuxsupport/rpms/HEP_OSlibs/raw/8.0.0-1.focal/downloads/heposlibs_8.0.0-1.focal_amd64.deb
sudo apt-get install ./heposlibs_8.0.0-1.focal_amd64.deb
rm -f cvmfs-release-latest_all.deb heposlibs_8.0.0-1.focal_amd64.deb
sudo apt-get update -y
sudo apt-get install -y cvmfs

# Ensure AutoFS is working
sudo cvmfs_config setup

# The configuration will be done on deployment so that we can populate
# the proxy addresses
