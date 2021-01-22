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
