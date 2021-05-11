#!/bin/bash

set -ex

sudo apt-get update

export ANACONDA_VER=3-2020.11

# Build tools and utilities
sudo apt-get install -y build-essential \
    vim emacs \
    zsh tcsh \
    postgresql mariadb-server sqlite3 \
    jq valgrind subversion htop \
    default-jre default-jdk \
    cgroup-lite \ 
    bvi mc cmake msmtp rlwrap sshfs

# Anaconda - includes all scientific tools that users may wish to use,
# and can create both python2 and 3 environments
wget https://repo.anaconda.com/archive/Anaconda${ANACONDA_VER}-Linux-x86_64.sh -O ~/anaconda.sh
sudo bash ~/anaconda.sh -b -p /opt/anaconda3
sudo chmod 755 -R /opt/anaconda3/
echo 'export PATH=$PATH:/opt/anaconda3/bin' | sudo tee -a /etc/bash.bashrc > /dev/null
rm -f ~/anaconda.sh

# Python 3
sudo apt-get install -y python3-dev python3-pip

# Python 2, libs, tools
sudo apt-get install -y python2 python2-dev
# Need to get pip manually
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
sudo python2 get-pip.py
rm -f get-pip.py

sudo reboot
