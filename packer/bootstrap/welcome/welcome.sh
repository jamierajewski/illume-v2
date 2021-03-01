#!/bin/bash

# Modify message of the day to show custom Illume one on
# user-facing nodes

# First, disable all current motd components
sudo chmod -x /etc/update-motd.d/*

# Now move custom welcome message script into place
sudo mv /home/ubuntu/01-illume-welcome /etc/update-motd.d/01-illume-welcome

# Finally, add permissions
sudo chmod +x /etc/update-motd.d/01-illume-welcome
