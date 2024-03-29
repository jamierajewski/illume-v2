# illume-v2
Rebuilding Illume cluster using VM workflow. Created to be as generic as possible to allow for use elsewhere.

[![license](https://img.shields.io/github/license/jamierajewski/illume-v2?color=success&style=plastic)](https://github.com/jamierajewski/illume-v2/blob/main/LICENSE)
[![issues](https://img.shields.io/github/issues/jamierajewski/illume-v2?color=critical&style=plastic)](https://github.com/jamierajewski/illume-v2/issues)
[![stars](https://img.shields.io/github/stars/jamierajewski/illume-v2?color=yellow&style=plastic)](https://github.com/jamierajewski/illume-v2/stargazers)
[![forks](https://img.shields.io/github/forks/jamierajewski/illume-v2?style=plastic)](https://github.com/jamierajewski/illume-v2/network/members)

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Build VM images](#build-vm-images)
- [Deploying to OpenStack](#deploying-to-openstack)
- [Monitoring](#monitoring)
- [How-to Guides](#how-to-guides)
  - [How to perform maintenance](#how-to-perform-maintenance)
  - [How to access LDAP interface](#how-to-access-ldap-interface)
  - [How to debug LDAP](#how-to-debug-ldap)
  - [How to deploy a test cluster](#how-to-deploy-a-test-cluster)
- [Authors and acknowledgements](#authors-and-acknowledgements)


## Overview

Illume is the infrastructure-as-code ready to deploy on OpenStack for HPC workloads. It contains:
- [HTCondor](https://htcondor.readthedocs.io/en/latest/overview/index.html), a batch scheduler for running user jobs
- [openLDAP](https://www.openldap.org/) and [phpLDAPadmin](http://phpldapadmin.sourceforge.net/wiki/index.php/Main_Page) for user account management
- [Prometheus](https://prometheus.io/docs/introduction/overview/) and [Grafana](https://grafana.com/), for monitoring physical hardware health (and potentially jobs, in the future)
- [CVMFS](https://cvmfs.readthedocs.io/en/stable/), for access to global project repositories of software and libraries
- [Squid Proxy](http://www.squid-cache.org/) for caching (particularly for CVMFS)
- [Nvidia CUDA](https://developer.nvidia.com/cuda-zone) drivers and libraries for accelerating workloads with GPUs
- [Rootless Podman](https://podman.io/#what-is-podman-podman-is-a-daemonless-container-engine-for-developing-managing-and-running-oci-containers-on-your-linux-system-containers-can-either-be-run-as-root-or-in-rootless-mode-simply-put-alias-dockerpodman-more-details-here) and [Singularity](https://sylabs.io/guides/3.7/user-guide/introduction.html) for safe container workloads
- [Anaconda](https://www.anaconda.com/) and [Jupyter](https://jupyter.org/) for a wide range of tools for users

Illume is designed for use with NFS for storage, but it shouldn't be too difficult to support other types.

This is achieved with a two-stage process - using [Packer](https://www.packer.io/) to build VM images with all appropriate software, and then deploying them via [Terraform](https://www.terraform.io/). Both of these are easily configurable to suit your needs; within the `/packer` directory you will find `/bootstrap`, which contains groups of scripts and configuration files used to install certain tools, and `/vm-profiles`, which contains the image definitions composed of these bootstrap scripts.

In the `/terraform` directory, you will find a collection of `host-` profiles, which are the profiles of the instances we want to create on the hardware. These can easily be scaled and customized to fit your hardware, and even modified (with a bit of work) to suit other infrastructure providers like AWS, as [Terraform offers API's for many of them](https://registry.terraform.io/browse/providers).

## Prerequisites
- Packer 1.7.2+
- Terraform 1.0.0+
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

**NOTE** - Certain information is not included in the repository, as it is hosted in an NFS drive which gets mounted when provisioned. This includes:
- LDAP configuration and database
- User home directories (that correspond to the LDAP accounts)
- Grafana and Prometheus dashboards and configuration

## Build VM Images
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

**NOTE** - When rebuilding the `worker-gpu` image, at least 1 GPU must be unassigned in OpenStack. This is because Packer will spin up an instance with a GPU to build the image, since it needs one in order for CUDA and other GPU packages to install and be tested correctly.

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

I have added metadata to the Packer images where appropriate to allow Prometheus to distinguish which nodes to scrape what information from, and one could add even more if they wish to add more exporters or rules.

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

## How-to Guides

### How to perform maintenance
If you want to perform software updates or install new software/tools, this will be done by modifying the corresponding Packer files; if you instead need to simply scale the number of nodes up/down, or make changes to a configuration within the Terraform directory, you can skip this section and move on to the Terraform section.

**Packer**
1. Make the changes to the relevant file(s); for example, if you wanted to install `htop` across the entire cluster, you would add it to `packer/bootstrap/common/common.sh`. If you only want to add it to user-facing instances, you can instead place it in `packer/bootstrap/tools/user-tools.sh`, which will install it on the ingress and all workers. If you simply want to perform an update to the currently installed software, move on to the next step.
2. After any changes have been made, you can rebuild the image(s). **IMPORTANT** - OpenStack doesn't seem to provide a timestamp to images, and a rebuild won't overwrite the older image, so it may be very confusing if you don't delete the current image(s) before rebuilding. I did include a condition in Terraform to choose the most recent image when provisioning, but it is best to delete old images that aren't needed anymore. Note the diagram in the [Build VM images](#build-vm-images) section for the order. You can also use the helper script `packer/vm-profiles/build-all.sh`, which contains the appropriate order for rebuilding the VMs. By rebuilding the images, you will also be performing a package update, so any pending security and package updates will be applied.
3. Now that the images are all rebuilt, you can move on to Terraform to provision instances with these images.

**Terraform**
1. Make changes to the relevant file(s); for example, to increase the number of 1080ti workers, modify the "1080ti" value in the "name_counts" variable in `variables.tf`. 
2. After making any changes, you can provision the cluster with `terraform apply -var-file="variables.tfvars"`. Terraform will scan the currently deployed cluster and compare it against your local profiles to find any changes. If any are found, it will redeploy the relevant instance(s). **IMPORTANT** - If a change is made to a template (under `terraform/templates`), Terraform may not be able to detect it as it is "user data" that is used as the cloud-config file to perform first-boot setup. In these cases, you can delete the instance(s) first, and then provision fresh ones.


### How to access LDAP interface
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

### How to debug LDAP
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
### How to deploy a test cluster
1. Clone the repository again, and rename it to `illume-v2-testing` to differentiate it from the production one
2. Follow the steps in [Prerequisites](#prerequisites) and [Deploying to OpenStack](#deploying-to-openstack) BUT DON'T PROVISION IT YET
3. Once the repo is populated with OpenStack credentials and initialized for Terraform, navigate to `terraform/variables.tfvars` and set `testing` to `true`. Then, set `local_subnet` to the illume-v1 subnet (to keep the test cluster isolated from the prod one). The `testing` variable will modify the instance names to have `-TESTING` appended to the end, along with switching the secgroups to using the illume-v1 variants
4. While still looking at `terraform/variables.tfvars`, set the appropriate number of worker instances at the bottom. Currently we want all GPUs (except for 1; see note in [Build VM images](#build-vm-images)) to be dedicated to production use, so you can likely only enable CPU-only configurations
5. Ensure you are in the `terraform` directory, then run `terraform apply -var-file="variables.tfvars"` to apply your configuration, which should deploy the test cluster without touching the production one. Verify that everything went as anticipated in the Cirrus control panel

## Authors and acknowledgements
Thanks to Claudio Kopper and David Schultz for mentoring and helping me - without them, this would not have been possible.
