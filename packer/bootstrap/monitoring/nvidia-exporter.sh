#!/bin/bash

set -ex

# Install the Nvidia GPU exporter (for GPU monitoring)
# Source: https://github.com/mindprince/nvidia_gpu_prometheus_exporter

sudo useradd --no-create-home --shell /sbin/nologin nvidia_exporter

# Source profile with Golang in the path
source /etc/profile.d/custom.sh

# No specific version as this was last updated in 2018 - just pull the latest
go get github.com/mindprince/nvidia_gpu_prometheus_exporter

# Move the binary to a permanent location with proper rights
sudo cp /home/ubuntu/go/bin/nvidia_gpu_prometheus_exporter /usr/local/bin
sudo chown nvidia_exporter:nvidia_exporter /usr/local/bin/nvidia_gpu_prometheus_exporter

# Create service for it
sudo tee /etc/systemd/system/nvidia_exporter.service > /dev/null <<EOT
[Unit]
Description=Nvidia GPU Prometheus Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=nvidia_exporter
Group=nvidia_exporter
Type=simple
ExecStart=/usr/local/bin/nvidia_gpu_prometheus_exporter

[Install]
WantedBy=multi-user.target
EOT

sudo systemctl daemon-reload
sudo systemctl start nvidia_exporter
sudo systemctl enable nvidia_exporter

# Cleanup
sudo rm -rf /home/ubuntu/go
