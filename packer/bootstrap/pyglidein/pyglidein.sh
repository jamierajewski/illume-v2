#!/bin/bash

# Set up pyglideins to run on illume-v2

# The profile already exists in the repo, so clone it and create the run script to activate it
git clone https://github.com/WIPACrepo/pyglidein.git
cd pyglidein

# Create the required secrets file (doesn't have to contain anything)
touch secrets
chmod 600 secrets

cat << EOF >> submit-glideins.sh
#!/bin/bash

python3 pyglidein/client.py --config=configs/illume-v2.config --secrets=secrets
EOF

chmod +x submit-glideins.sh

# Before starting, ensure that condor is configured to treat these jobs as backfill with preemption

# Set the priority factor to something obscenely large (aka a very low priority)
condor_userprio -setfactor pyglidein 10000000

