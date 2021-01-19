#!/bin/bash 

set -ex

# This will set up the variables ahead of time so that we can skip the
# ncurses interactive setup
export DEBIAN_FRONTEND=noninteractive
sudo debconf-set-selections <<EOF
ldap-auth-config ldap-auth-config/bindpw password placeholder	
ldap-auth-config ldap-auth-config/rootbindpw password placeholder	
ldap-auth-config ldap-auth-config/override boolean true
ldap-auth-config ldap-auth-config/move-to-debconf boolean true
ldap-auth-config ldap-auth-config/ldapns/base-dn string dc=illume,dc=systems
ldap-auth-config ldap-auth-config/rootbinddn string cn=admin,dc=illume,dc=systems
ldap-auth-config ldap-auth-config/ldapns/ldap_version select 3
ldap-auth-config ldap-auth-config/pam_password select md5
ldap-auth-config ldap-auth-config/dblogin boolean false
ldap-auth-config ldap-auth-config/ldapns/ldap-server string ldapi:///ldap_ip
ldap-auth-config ldap-auth-config/dbrootlogin boolean true
ldap-auth-config ldap-auth-config/binddn string cn=proxyuser,dc=example,dc=net
EOF

# Configure client to authenticate using LDAP
# Source: https://www.techrepublic.com/article/how-to-authenticate-a-linux-client-with-ldap-server/
sudo apt-get install libnss-ldap libpam-ldap ldap-utils nscd -y

# Configure client to authenticate against the openLDAP server
sudo sed '/passwd/ s/$/ ldap/' /etc/nsswitch.conf
sudo sed '/group/ s/$/ ldap/' /etc/nsswitch.conf
sudo sed '/^shadow/ s/$/ ldap/' /etc/nsswitch.conf
sudo sed 's/use_authtok//' /etc/pam.d/common-password

# Add rule to create home directory for users if it doesn't exist
echo "session optional pam_mkhomedir.so skel=/etc/skel umask=077" | sudo tee -a /etc/pam.d/common-session > /dev/null

# Ensure that terraform will now create the /etc/ldap.secret file with the admin pass
