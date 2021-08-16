#!/bin/bash 

set -ex

# Install openLDAP using automated configuration
# This ultimately doesn't matter as it will be overwritten with
# the Illume configuration in the next step
# Source: https://stackoverflow.com/a/29277856
export DEBIAN_FRONTEND=noninteractive
sudo debconf-set-selections <<EOF
slapd slapd/internal/generated_adminpw password replace_me
slapd slapd/password2 password replace_me
slapd slapd/internal/adminpw password replace_me
slapd slapd/password1 password replace_me
slapd slapd/domain string illume.systems
slapd shared/organization string Illume Systems
EOF

sudo apt-get install -y slapd ldap-utils

# ==== CURRENTLY UNUSED DUE TO MOUNTING FROM AN NFS ==== #

# Restore the configuration and database from the copy in this repo
# This requires having a backed up DATABASE.ldif and CONFIG.ldif in ldap/ldap-backup directory
# Source: https://serverfault.com/a/796163
# Steps are followed from 4 onward from the above source

# # Stop the LDAP service to make changes safely
# sudo service slapd stop

# # Delete old configuration
# sudo rm -rf /etc/ldap/slapd.d/*

# # Restore configuration
# sudo slapadd -n 0 -F /etc/ldap/slapd.d -l /home/ubuntu/CONFIG.ldif

# # Restore database
# sudo slapadd -n 1 -l /home/ubuntu/DATABASE.ldif

# # Change permissions of the slapd.d directory and contents
# sudo chown -R openldap /etc/ldap/slapd.d
# sudo chmod -R 755 /etc/ldap/slapd.d

# # Change permissions of ldap directory and contents
# sudo chown -R openldap /var/lib/ldap
# sudo chmod -R 755 /var/lib/ldap

# # Restart slapd now that we are done
# sudo service slapd start
