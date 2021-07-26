#!/bin/bash

set -e

printf "\t\t\t\t\t[ Illume v2 - Builder CLI ]\n"

STAGES=8
if [[ $# -eq 1 && $1 -gt 0 && $1 -le $STAGES ]]; then
    STAGES=$1
fi

# Non-interactive and interactive
if [[ $STAGES -ge 1 ]]; then
    cd base
    packer build -force non-interactive.pkr.hcl
    packer build -force interactive.pkr.hcl
    cd ..
fi

if [[ $STAGES -ge 2 ]]; then
    cd bastion
    packer build -force bastion.pkr.hcl
    cd ..
fi

if [[ $STAGES -ge 3 ]]; then
    cd ingress
    packer build -force ingress.pkr.hcl
    cd ..
fi

if [[ $STAGES -ge 4 ]]; then
    cd monitor
    packer build -force monitor.pkr.hcl
    cd ..
fi

if [[ $STAGES -ge 5 ]]; then
    cd ldap
    packer build -force openLDAP.pkr.hcl
    packer build -force phpLDAPadmin.pkr.hcl
    cd ..
fi

if [[ $STAGES -ge 6 ]]; then
    cd proxy
    packer build -force proxy.pkr.hcl
    cd ..
fi

if [[ $STAGES -ge 7 ]]; then
    cd control
    packer build -force control.pkr.hcl
    cd ..
fi

if [[ $STAGES -eq 8 ]]; then
    cd worker
    packer build -force worker-gpu.pkr.hcl
    packer build -force worker-nogpu.pkr.hcl
    cd ..
fi
