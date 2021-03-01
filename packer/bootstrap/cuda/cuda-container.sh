#!/bin/bash

set -ex

# This script is primarily to make GPUs work in Podman containers

# Install the nvidia-container-toolkit to use GPUs within podman
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit nvidia-container-runtime runc

# Custom configuration to get GPUs to work with podman
# Source: https://gist.github.com/bernardomig/315534407585d5912f5616c35c7fe374

# Create the prestart hook
sudo mkdir -p /usr/share/containers/oci/hooks.d/
echo '
{
  "hook": "/usr/bin/nvidia-container-runtime-hook",
  "arguments": ["prestart"],
  "annotations": ["sandbox"],
  "stage": [ "prestart" ]
}
' | sudo tee /usr/share/containers/oci/hooks.d/oci-nvidia-hook.json > /dev/null

# Configure the nvidia-container-runtime
echo '
disable-require = false
#swarm-resource = "DOCKER_RESOURCE_GPU"
#accept-nvidia-visible-devices-envvar-when-unprivileged = true
#accept-nvidia-visible-devices-as-volume-mounts = false

[nvidia-container-cli]
#root = "/run/nvidia/driver"
#path = "/usr/bin/nvidia-container-cli"
environment = []
debug = "/tmp/nvidia-container-toolkit.log"
#ldcache = "/etc/ld.so.cache"
load-kmods = true
no-cgroups = true
#user = "root:video"
ldconfig = "@/sbin/ldconfig.real"

[nvidia-container-runtime]
debug = "/tmp/nvidia-container-runtime.log"
' | sudo tee /etc/nvidia-container-runtime/config.toml > /dev/null

# Make fewer required command line options necessary
# Source: https://github.com/NVIDIA/nvidia-container-runtime/issues/85#issuecomment-650442694
# The configuration is already done in the premade config, so put it in the right place
cat /home/ubuntu/containers.conf | sudo tee /etc/containers/containers.conf > /dev/null
sudo rm /home/ubuntu/containers.conf
