#!/bin/bash

set -ex

# Source: 
# https://www.scaleway.com/en/docs/configure-prometheus-monitoring-with-grafana/#-Installing-Grafana

# Since dashboards need to be set up manually after deployment, here are the ones
# I use:
# 1. Nvidia Metrics (https://grafana.com/grafana/dashboards/10703)
# 2. Node Exporter Full (https://grafana.com/grafana/dashboards/1860)

export GRAF_VER=7.4.3

# Fetch and install pinned Grafana release - the installation will also create
# the 'Grafana' user which will run the service
sudo apt-get install -y adduser libfontconfig1
wget https://dl.grafana.com/oss/release/grafana_${GRAF_VER}_amd64.deb
sudo dpkg -i grafana_${GRAF_VER}_amd64.deb
sudo rm -f grafana_${GRAF_VER}_amd64.deb

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
