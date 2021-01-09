# Configure the OpenStack Provider
provider "openstack" {
  user_name   = var.username
  tenant_name = "IceCube"
  tenant_id   = var.tenant_id
  password    = var.password
  auth_url    = var.auth_url
  region      = "RegionOne"
  domain_name = "CCDB"
}

