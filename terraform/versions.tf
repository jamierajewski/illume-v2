terraform {
  required_version = "~> 0.15.3"
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "~> 1.34.1"
    }
  }
}
