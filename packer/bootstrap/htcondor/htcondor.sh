#!/bin/bash

set -ex

# Install HTCondor by following the Ubuntu instructions:
# https://research.cs.wisc.edu/htcondor/instructions/ubuntu/20/development/

# Add repo
wget -qO - https://research.cs.wisc.edu/htcondor/ubuntu/HTCondor-Release.gpg.key | sudo apt-key add -
echo "deb http://research.cs.wisc.edu/htcondor/ubuntu/8.9/focal focal contrib" | sudo tee -a /etc/apt/sources.list > /dev/null
echo "deb-src http://research.cs.wisc.edu/htcondor/ubuntu/8.9/focal focal contrib" | sudo tee -a /etc/apt/sources.list > /dev/null

# Install static version (8.9.11) from repo
sudo apt-get update
sudo apt-get install -y htcondor=8.9.11-1.2
