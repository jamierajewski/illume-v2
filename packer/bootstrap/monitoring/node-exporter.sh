#!/bin/bash

set -ex

# Install the Node exporter (for system details)
# Source: https://www.scaleway.com/en/docs/configure-prometheus-monitoring-with-grafana/#-Downloading-and-Installing-Node-Exporter

export NODE_VER=1.1.2

sudo useradd --no-create-home --shell /sbin/nologin node_exporter

wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_VER}/node_exporter-${NODE_VER}.linux-amd64.tar.gz
tar xvfz node_exporter-${NODE_VER}.linux-amd64.tar.gz

# Move the binary to a permanent location with proper rights
sudo cp node_exporter-${NODE_VER}.linux-amd64/node_exporter /usr/local/bin
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Create service for it
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOT
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOT

sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# Cleanup
sudo rm -rf /home/ubuntu/node_exporter*
