#!/bin/bash 

set -ex

# Install Squid package
sudo apt-get install -y squid

# Create squid user
sudo useradd squid
