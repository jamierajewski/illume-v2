#!/bin/bash -l

# Source OpenStack config and SSH key location
export SSH_KEY_SOURCE="path/to/ssh/key/for/packer"
# This OpenStack config can be retrieved by:
# - Logging into OpenStack
# - Click username in top right
# - Click "OpenStack RC V3"
source "path/to/openstack/RC"
