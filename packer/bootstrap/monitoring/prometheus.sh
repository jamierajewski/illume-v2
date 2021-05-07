#!/bin/bash

set -ex

# Source: 
# https://www.scaleway.com/en/docs/configure-prometheus-monitoring-with-grafana/

# To configure automatic scraping of nodes, refer to the following guide:
# https://medium.com/@pasquier.simon/monitoring-your-openstack-instances-with-prometheus-a7ff4324db6c
export PROM_VER=2.26.0

# Create service accounts for Prometheus and the exporters
sudo useradd --no-create-home --shell /sbin/nologin prometheus

sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

# Move the config file to the proper location (ownership gets fixed below)
sudo mv prometheus.yml /etc/prometheus/prometheus.yml

# Fetch Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VER}/prometheus-${PROM_VER}.linux-amd64.tar.gz
tar xvfz prometheus-*.tar.gz

# Move binaries on to PATH and set ownership
sudo cp prometheus-${PROM_VER}.linux-amd64/prometheus /usr/local/bin
sudo cp prometheus-${PROM_VER}.linux-amd64/promtool /usr/local/bin
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

# Move the libs to the config location and change ownership
sudo cp -r prometheus-${PROM_VER}.linux-amd64/console* /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus

# Change permission of lib
sudo chown -R prometheus:prometheus /var/lib/prometheus

# Create Prometheus systemd service
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOT
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOT

# Cleanup
sudo rm -rf /home/ubuntu/prometheus-*
