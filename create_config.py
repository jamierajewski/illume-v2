#!/usr/bin/env python3

# Originally written by Claudio Kopper
# Modifications by Jamie Rajewski

import os
import json
import subprocess
from string import Template

def create_ssh_config(data, outfile):

    # Add universal options here first
    result = "Host *\n  IdentitiesOnly yes\n\n"

    ssh_username = data['ssh-username']['value']
    ssh_keyfile  = data['ssh-key-file']['value']
    bastion_host_public = data['bastion-address-public']['value']
    bastion_hostname = "illume-bastion-v2"

    # Substitute vars in template
    filein = open("packer/bootstrap/ssh/ssh.cfg.template.per_host")
    src = Template(filein.read())
    del filein

    d = {
        'hostname':bastion_hostname,
        'host_ip':bastion_host_public,
        'ssh_username':ssh_username,
        'ssh_keyfile':ssh_keyfile,
        'proxy_jump': 'None',
        }
    result += src.substitute(d) + "\n"

    for idx, address in enumerate(data['illume-proxy-addresses']['value']):
        d = {
            'hostname':"illume-proxy-{:02d}-v2".format(idx+1),
            'host_ip':address,
            'ssh_username':ssh_username,
            'ssh_keyfile':ssh_keyfile,
            'proxy_jump':bastion_hostname,
            }
        result += src.substitute(d) + "\n"

    for idx, address in enumerate(data['illume-control-addresses']['value']):
        d = {
            'hostname':"illume-control-{:02d}-v2".format(idx+1),
            'host_ip':address,
            'ssh_username':ssh_username,
            'ssh_keyfile':ssh_keyfile,
            'proxy_jump':bastion_hostname,
            }
        result += src.substitute(d) + "\n"
    for instance in data['illume-worker-addresses']['value']:
        d = {
            'hostname':instance,
            'host_ip':data['illume-worker-addresses']['value'][instance],
            'ssh_username':ssh_username,
            'ssh_keyfile':ssh_keyfile,
            'proxy_jump':bastion_hostname,
            }
        result += src.substitute(d) + "\n"
    for idx, address in enumerate(data['illume-ingress-addresses']['value']):
        d = {
            'hostname':"illume-ingress-{:02d}-v2".format(idx+1),
            'host_ip':address,
            'ssh_username':ssh_username,
            'ssh_keyfile':ssh_keyfile,
            'proxy_jump':bastion_hostname,
            }
        result += src.substitute(d) + "\n"

    for idx, address in enumerate(data['illume-openLDAP-addresses']['value']):
        d = {
            'hostname':"illume-openLDAP-{:02d}-v2".format(idx+1),
            'host_ip':address,
            'ssh_username':ssh_username,
            'ssh_keyfile':ssh_keyfile,
            'proxy_jump':bastion_hostname,
            }
        result += src.substitute(d) + "\n"

    for idx, address in enumerate(data['illume-phpLDAPadmin-addresses']['value']):
        d = {
            'hostname':"illume-phpLDAPadmin-{:02d}-v2".format(idx+1),
            'host_ip':address,
            'ssh_username':ssh_username,
            'ssh_keyfile':ssh_keyfile,
            'proxy_jump':bastion_hostname,
            }
        result += src.substitute(d) + "\n"

    for idx, address in enumerate(data['illume-monitor-addresses']['value']):
        d = {
            'hostname':"illume-monitor-{:02d}-v2".format(idx+1),
            'host_ip':address,
            'ssh_username':ssh_username,
            'ssh_keyfile':ssh_keyfile,
            'proxy_jump':bastion_hostname,
            }
        result += src.substitute(d) + "\n"

    text_file = open(outfile, "w")
    text_file.write(result)
    text_file.close()


def main():
    # get data from  terraform output for injection in template
    tf_output= subprocess.Popen("terraform output -state=terraform/terraform.tfstate -json", shell=True, stdout=subprocess.PIPE).stdout.read()
    data = json.loads(tf_output)

    # Write ssh config (for localhost)
    create_ssh_config(data, outfile="ssh.cfg")


if __name__ == '__main__':
    main()
