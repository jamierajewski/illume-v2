# illume-v2
Rebuilding Illume cluster using VM workflow. Created to be as generic as possible to allow for use elsewhere.

[![license](https://img.shields.io/github/license/jamierajewski/illume-v2?color=success&style=plastic)](https://github.com/jamierajewski/illume-v2/blob/main/LICENSE)
[![issues](https://img.shields.io/github/issues/jamierajewski/illume-v2?color=critical&style=plastic)](https://github.com/jamierajewski/illume-v2/issues)
[![stars](https://img.shields.io/github/stars/jamierajewski/illume-v2?color=yellow&style=plastic)](https://github.com/jamierajewski/illume-v2/stargazers)
[![forks](https://img.shields.io/github/forks/jamierajewski/illume-v2?style=plastic)](https://github.com/jamierajewski/illume-v2/network/members)

## Table of Contents

- [Prerequisites](#prerequisites)
- [Rebuild VM Images](#rebuild-vm-images)
- [Deploying to OpenStack](#deploying-to-openstack)
- [Monitoring](#monitoring)
- [How to access LDAP interface](#how-to-access-ldap-interface)
- [How to Debug](#how-to-debug)
  * [LDAP](#ldap)
- [Authors and acknowledgements](#authors-and-acknowledgements)


## Prerequisites
- Packer 1.7.0+
- Terraform 0.14.5+
- OpenStack RC File (can be retrieved by logging into OpenStack -> click username in the top right -> Download `OpenStack RC File V3`)
- An SSH key pair for provisioning
- (Optional) [OpenStack Client](https://docs.openstack.org/newton/user-guide/common/cli-install-openstack-command-line-clients.html) - This is helpful for retrieving information from OpenStack like flavors etc.

Fill in `/setup-env.sh` with your SSH key location and the path to the OpenStack RC file, and then run it. You also need to create a file called `/terraform/variables.tfvars` with assignments for the secret variables in `/terraform/variables.tf`. You can also leave the fields in `/terraform/variables.tf` as
```
{
    default = ""
}
```

if you want to be prompted for them each time you run a Terraform command. DO NOT FILL IN `/terraform/variables.tf`; instead, fill in `/terraform/variables.tfvars` which allows you to keep your credentials separated from the variable template. **DO NOT COMMIT WITH YOUR INFORMATION FILLED IN**.

## Rebuild VM Images
The VM images are located under `/packer/vm-profiles`. The images are dependent on one another in sensical ways to keep build times down the higher up the stack you go, while also keeping the profiles themselves concise and lacking repetition. The hierarchy is as follows:

```
 non-interactive ->|-> openLDAP
                   |-> proxy
                   |-> monitor
                   |-> control
                   |-> phpLDAPadmin
                   |-> interactive ->|-> bastion
                                     |-> ingress
                                     |-> worker-nogpu ->|-> worker-gpu               
```
This organization also makes it easier to make changes to multiple images while only modifying one.
For example, if you wanted to add `numpy`, you could add it to `interactive` and then rebuild the
images that depend on it, giving them all numpy.

## Deploying to OpenStack
As with the VM images, the Terraform deployment profiles are set up with dependencies so that post-provisioning can be done once the appropriate instances are deployed. However, Terraform takes care of building them in the correct order so you only need to:
- Navigate to `/terraform`
- Run `terraform init`
- Run `terraform plan -var-file="variables.tfvars"` to verify your changes. This will fill in the variables with your `.tfvars` file created above
- Once happy, run `terraform apply -var-file="variables.tfvars"` which you can then accept if it looks good

You can then view the provisioned instances in the OpenStack dashboard under **Compute** -> **Instances**.

## Monitoring
Illume v2 uses **Prometheus** to scrape data from nodes, and **Grafana** to visualize that data. Currently, there are only two exporters in use:
- **Node exporter**, which advertises tons of hardware, OS and networking data (runs on ALL nodes)
- **Nvidia exporter**, which advertises various data related to GPUs (only runs on GPU workers)

I have added metadata to the Packer images where appropriate to allow Prometheus to distinguish which nodes to scrape what information from, and one could add
even more if they wish to add more exporters or rules.

Grafana cannot be set up automatically, and so one must log in and configure the dashboard accordingly. The steps to do so are:
1. Create (if it doesn't already exist) `~/.ssh/config`
2. Create an entry for the `bastion` host that looks something like this with the public IP and path to key filled in:
```
Host bastion                                                                                          
     HostName xxx.xxx.xxx.xxx (public IP)                                                                            
     User ubuntu                                                                                         
     IdentityFile /path/to/key
```
3. Test the above to make sure it works by saving it, then run `ssh bastion`
4. Now that the bastion connection works, create a second entry in `~/.ssh/config` like this:
```
Host grafana                                                                                     
     User ubuntu                                                                                         
     HostName xxx.xxx.xxx.xxx (fixed IP)                                                                             
     IdentityFile /path/to/key                                                                      
     ProxyJump bastion                                                                                
     LocalForward 3000 localhost:3000
```
Since Grafana is only hosted internally, we must forward port 3000 and then connect via the bastion as that is the only way into the network from the outside (aside from the ingress). `ProxyJump` will perform this intermediate connection.

5. Once that is working and you have successfully logged into the Grafana instance, move to your web browser and put in 
```
http://localhost:3000
```
If everything was done correctly then you should have landed on the Grafana login page.

6. Enter the following defaults:
```
Username: admin
Password: admin
```
You will be prompted to change the password - do so now.

7. Click the gear icon on the left sidebar, navigate to "Data Sources" and click "Add data source"
8. The first option should be "Prometheus" - click that
9. Under the HTTP section, enter `http://localhost:9090` for the URL and then scroll to the bottom and click "Save & Test". It should show a green "success" message.
10. Now that Prometheus is set up, we need to import pre-made dashboards to use for each of the data types that are being exported. In the left sidebar hover over the "+" icon and click "Import"
11. In the bar that says "Import via grafana.com", input **1860** and click load. This should fill in information telling you that you are trying to import a Node Exporter dashboard
12. In the dropdown at the bottom, select the Prometheus instance we just set up and click import.
13. Repeat the above steps for importing but this time use the ID **10703** which is for the Nvidia exporter.

Once saved, the dashboards are successfully set up.

## How to access LDAP interface
Illume v2 uses **phpLDAPadmin** as an interface over **openLDAP**. To access the web interface for easy account management:
1. Create (if it doesn't already exist) `~/.ssh/config`
2. Create an entry for the `bastion` host that looks something like this with the public IP and path to key filled in:
```
Host bastion                                                                                          
     HostName xxx.xxx.xxx.xxx (public IP)                                                                            
     User ubuntu                                                                                         
     IdentityFile /path/to/key
```
3. Test the above to make sure it works by saving it, then run `ssh bastion`
4. Now that the bastion connection works, create a second entry in `~/.ssh/config` like this:
```
Host phpLDAPadmin                                                                                     
     User ubuntu                                                                                         
     HostName xxx.xxx.xxx.xxx (fixed IP)                                                                             
     IdentityFile /path/to/key                                                                      
     ProxyJump bastion                                                                                
     LocalForward 8080 localhost:80
```
Since the LDAP server and php interface are hosted internally only, we must forward port 80 and then connect via the bastion as that is the only way into the network from the outside (aside from the ingress). `ProxyJump` will perform this intermediate connection.

5. Once that is working and you have successfully logged into the php instance, move to your web browser and put in 
```
http://localhost:8080/phpldapadmin/
```
If everything was done correctly then you should have landed on the phpLDAPadmin login page.

# How to Debug
## LDAP
LDAP is one of the more complicated parts of the cluster. To ensure that it is working, you can `ssh` into the `openLDAP` instance (via the Bastion since it isn't exposed to the internet) and run
```
ldapsearch -x -b cn=First Last,ou=users,dc=illume,dc=systems
```
where `First Last` is the users' full name. This line can also be retrieved from phpLDAPadmin's web interface by choosing a user and clicking `Show internal attributes`.

If the LDAP server is successfully running, you should see output like
```
# extended LDIF
#
# LDAPv3
# base <cn=First Last,ou=users,dc=illume,dc=systems> with scope subtree
# filter: (objectclass=*)
# requesting: ALL
#

# First Last, users, illume.systems
dn: cn=Test Man,ou=users,dc=illume,dc=systems
cn: First Last
givenName: First
gidNumber: 501
homeDirectory: /home/users/flast
sn: Last
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: top
uidNumber: 1050
uid: flast
loginShell: /bin/bash

# search result
search: 2
result: 0 Success

# numResponses: 2
# numEntries: 1
```

## Authors and acknowledgements
Thanks to Claudio Kopper and David Schultz for mentoring and helping me - without them, this would not have been possible.
