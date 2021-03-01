#!/bin/bash 

set -ex

# Install Nvidia Driver / CUDA toolkit (stable older driver to work on older GPUs like the 980)
sudo apt-get update
sudo apt-get install -y nvidia-driver-455 nvidia-cuda-toolkit

# Add CUDA_PATH to PATH
echo 'export CUDA_PATH=/usr' | sudo tee -a /etc/profile.d/custom.sh > /dev/null

# Finalize driver installation with reboot
sudo reboot
