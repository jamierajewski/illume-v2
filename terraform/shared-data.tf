data "openstack_images_image_v2" "worker-image-gpu" {
  name        = "illume-worker-gpu"
  most_recent = true
}

data "openstack_images_image_v2" "worker-image-nogpu" {
  name        = "illume-worker-nogpu"
  most_recent = true
}

# Fill out the templates here which we can then pass to the appropriate instances
locals {
  worker-whole-template = templatefile("${path.module}/templates/worker.yml", 
  {
    partition_1 = 90
    partition_2 = 5
    partition_3 = 5
    proxy1_IP = openstack_compute_instance_v2.illume-proxy-v2[0].network[0].fixed_ip_v4
    proxy2_IP = openstack_compute_instance_v2.illume-proxy-v2[1].network[0].fixed_ip_v4
    openLDAP_IP = openstack_compute_instance_v2.illume-openLDAP-v2.network[0].fixed_ip_v4
    LDAP_admin_pass = var.ldap_admin_pass
    condor_control_IP = openstack_compute_instance_v2.illume-control-v2.network[0].fixed_ip_v4
    condor_pool_pass = var.condor_pass
  })

  worker-half-template = templatefile("${path.module}/templates/worker.yml", 
  {
    partition_1 = 70
    partition_2 = 15
    partition_3 = 15
    proxy1_IP = openstack_compute_instance_v2.illume-proxy-v2[0].network[0].fixed_ip_v4
    proxy2_IP = openstack_compute_instance_v2.illume-proxy-v2[1].network[0].fixed_ip_v4
    openLDAP_IP = openstack_compute_instance_v2.illume-openLDAP-v2.network[0].fixed_ip_v4
    LDAP_admin_pass = var.ldap_admin_pass
    condor_control_IP = openstack_compute_instance_v2.illume-control-v2.network[0].fixed_ip_v4
    condor_pool_pass = var.condor_pass
  })

  worker-quarter-template = templatefile("${path.module}/templates/worker.yml", 
  {
    partition_1 = 50
    partition_2 = 20
    partition_3 = 30
    proxy1_IP = openstack_compute_instance_v2.illume-proxy-v2[0].network[0].fixed_ip_v4
    proxy2_IP = openstack_compute_instance_v2.illume-proxy-v2[1].network[0].fixed_ip_v4
    openLDAP_IP = openstack_compute_instance_v2.illume-openLDAP-v2.network[0].fixed_ip_v4
    LDAP_admin_pass = var.ldap_admin_pass
    condor_control_IP = openstack_compute_instance_v2.illume-control-v2.network[0].fixed_ip_v4
    condor_pool_pass = var.condor_pass
  })

  phpLDAPadmin-template = templatefile("${path.module}/templates/phpLDAPadmin.yml", 
  {
    openLDAP_IP = openstack_compute_instance_v2.illume-openLDAP-v2.network[0].fixed_ip_v4
  })

  control-template = templatefile("${path.module}/templates/control.yml", 
  {
    condor_pool_pass = var.condor_pass
  })

  ingress-template = templatefile("${path.module}/templates/ingress.yml", 
  {
    proxy1_IP = openstack_compute_instance_v2.illume-proxy-v2[0].network[0].fixed_ip_v4
    proxy2_IP = openstack_compute_instance_v2.illume-proxy-v2[1].network[0].fixed_ip_v4
    openLDAP_IP = openstack_compute_instance_v2.illume-openLDAP-v2.network[0].fixed_ip_v4
    LDAP_admin_pass = var.ldap_admin_pass
    condor_control_IP = openstack_compute_instance_v2.illume-control-v2.network[0].fixed_ip_v4
    condor_pool_pass = var.condor_pass
  })
}
