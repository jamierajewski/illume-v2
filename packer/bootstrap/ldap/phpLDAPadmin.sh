#!/bin/bash 

set -ex

# Install Apache which will host the web interface
sudo apt-get install -y apache2

# Install old PHP 5 since that is what phpLDAPadmin supports
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:ondrej/php
sudo add-apt-repository -y ppa:ondrej/apache2
sudo apt-get update
sudo apt-get install -y php5.6 php5.6-ldap php5.6-xml

# Install phpLDAPadmin and configure it
sudo apt-get install -y phpldapadmin
