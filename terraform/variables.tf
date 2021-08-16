//-----Basic Configuration-----//
variable "username" {
  description = "OpenStack username"
  type = string
}

variable "password" {
  description = "OpenStack password"
  type = string
  sensitive = true
}

variable "ldap_admin_pass" {
  description = "LDAP administrator password"
  type = string
  sensitive = true
}

variable "condor_pass" {
  description = "Condor pool password"
  type = string
  sensitive = true
}

variable "tenant_id" {
  description = "OpenStack Tenant ID (found in OpenStack RC file)"
  type = string
}

variable "auth_url" {
  description = "Authorization URL (found in OpenStack RC file)"
  type = string
}

variable "id_endpoint" {
  description = "Same as auth_url, but with forward slashes delimited (to avoid issues with sed in the monitor.yml cloud-init). To
  delimit a backslash, use two back slashes like \\/"
  type = string
}

variable "ssh_key_file" {
  description = "Absolute path to SSH key to add to instances"
  type = string
}

variable "ssh_user_name" {
  description = "Username to use in conjunction with SSH key"
  type = string
}

variable "floating_ip_pool" {
  description = "Pool to pull floating IP's from (found on OpenStack)"
  type = string
}

variable "network" {
  description = "Name of the network to attach instances to"
  type = string
}

variable "local_subnet" {
  description = "Subnet of the cluster"
  type = string
}

variable "region" {
  description = "Region where the instances will be hosted (found in OpenStack RC file)"
  default = "RegionOne"
}

variable "domain_name" {
  description = "Domain which will host the instances (found in OpenStack RC file)"
  type = string
}

variable "project_id" {
  description = "Project ID (found in OpenStack RC file)"
  type = string
}

variable "tenant_name" {
  description = "Name of the tenant (found in the OpenStack RC file)"
  type = string
}

//-----NFS Mounts-----//
variable "nfs_data1" {
  description = "NFS location for /data1"
  type = string
}

variable "nfs_data2" {
  description = "NFS location for /data2"
  type = string
}

variable "nfs_home" {
  description = "NFS location for /home"
  type = string
}

//-----Static IPs-----//
variable "ingress_ip" {
  description = "Floating IP to assign to the ingress"
  type = string
}

variable "bastion_ip" {
  description = "Floating IP to assign to the bastion"
  type = string
}

variable "testing" {
  description = "Whether or not testing mode is enabled (changes instance names)"
  type = bool
  default = false
}

//-----Instance counts-----//
variable "name_counts" {
  description = "A map containing the counts for each type of instance. Changing these will change the amount deployed"
  type = map(number)
  default = {
    "interactive" = 0
    "1080ti"      = 0
    "980"         = 0
    "980ti"       = 0
    "titanxp"     = 0
    "titanx"      = 0
    "whole"       = 0
    "half"        = 0
    "quarter"     = 0
  }
}
