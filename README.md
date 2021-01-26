# illume-v2
Rebuilding Illume cluster using VM workflow

## Prerequisites
- Packer 1.6.4+
- Terraform 0.14.5+
- OpenStack RC File (can be retrieved by logging into OpenStack -> click username in the top right -> Download `OpenStack RC File V3`)
- An SSH key pair for provisioning
- (Optional) [OpenStack Client](https://docs.openstack.org/newton/user-guide/common/cli-install-openstack-command-line-clients.html) - This is helpful for retrieving information from OpenStack like flavors etc.

Fill in `/setup-env.sh` with your SSH key location and the path to the OpenStack RC file, and then run it. You also need to fill in `/terraform/variables.tf` with the relevant OpenStack information. You can also leave the fields as
```
{
    default = ""
}
```

if you want to be prompted for them each time you run a Terraform command. DO NOT COMMIT WITH YOUR INFORMATION FILLED IN.

## Rebuild VM Images
The VM images are located under `/packer/vm-profiles`. The images are dependent on one another in sensical ways to keep build times down the higher up the stack you go, while also keeping the profiles themselves concise and lacking repetition. The hierarchy is as follows:

```
 non-interactive ->|-> openLDAP
                   |-> proxy
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
- Run `terraform plan` to verify your changes
- Once happy, run `terraform apply` which you can then accept if it looks good

You can then view the provisioned instances in the OpenStack dashboard under **Compute** -> **Instances**.

## How to access LDAP interface
Illume v2 uses phpLDAPadmin as an interface over openLDAP. To access the web interface for easy account management:
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

## How to Debug
# LDAP
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

