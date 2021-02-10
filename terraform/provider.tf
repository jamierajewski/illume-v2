# Configure the OpenStack Provider
provider "openstack" {
  user_name   = var.username
  tenant_name = var.tenant_name
  tenant_id   = var.tenant_id
  password    = var.password
  auth_url    = var.auth_url
  region      = var.region
  domain_name = var.domain_name
}

