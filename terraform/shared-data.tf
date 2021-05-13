data "openstack_images_image_v2" "worker-image-gpu" {
  name        = "illume-worker-gpu"
  most_recent = true
}

data "openstack_images_image_v2" "worker-image-nogpu" {
  name        = "illume-worker-nogpu"
  most_recent = true
}

# Render templates which will then be passed to the appropriate instance
locals {
  worker-whole-template = templatefile("${path.module}/templates/worker.yml", 
  {
    partition_1 = 90
    partition_2 = 5
    partition_3 = 5
    interactive_command = "echo"
    proxy1_IP = openstack_compute_instance_v2.illume-proxy-v2[0].network[0].fixed_ip_v4
    proxy2_IP = openstack_compute_instance_v2.illume-proxy-v2[1].network[0].fixed_ip_v4
    openLDAP_IP = openstack_compute_instance_v2.illume-openLDAP-v2.network[0].fixed_ip_v4
    LDAP_admin_pass = var.ldap_admin_pass
    condor_control_IP = openstack_compute_instance_v2.illume-control-v2.network[0].fixed_ip_v4
    condor_pool_pass = var.condor_pass
    nfs_data1 = var.nfs_data1
    nfs_data2 = var.nfs_data2
    nfs_home = var.nfs_home
  })

  worker-interactive-template = templatefile("${path.module}/templates/worker.yml", 
  {
    partition_1 = 90
    partition_2 = 5
    partition_3 = 5
    interactive_command = "sudo mv /etc/condor/condor_config_interactive.local /etc/condor/condor_config.local"
    proxy1_IP = openstack_compute_instance_v2.illume-proxy-v2[0].network[0].fixed_ip_v4
    proxy2_IP = openstack_compute_instance_v2.illume-proxy-v2[1].network[0].fixed_ip_v4
    openLDAP_IP = openstack_compute_instance_v2.illume-openLDAP-v2.network[0].fixed_ip_v4
    LDAP_admin_pass = var.ldap_admin_pass
    condor_control_IP = openstack_compute_instance_v2.illume-control-v2.network[0].fixed_ip_v4
    condor_pool_pass = var.condor_pass
    nfs_data1 = var.nfs_data1
    nfs_data2 = var.nfs_data2
    nfs_home = var.nfs_home
  })

  worker-half-template = templatefile("${path.module}/templates/worker.yml", 
  {
    partition_1 = 70
    partition_2 = 15
    partition_3 = 15
    interactive_command = "echo"
    proxy1_IP = openstack_compute_instance_v2.illume-proxy-v2[0].network[0].fixed_ip_v4
    proxy2_IP = openstack_compute_instance_v2.illume-proxy-v2[1].network[0].fixed_ip_v4
    openLDAP_IP = openstack_compute_instance_v2.illume-openLDAP-v2.network[0].fixed_ip_v4
    LDAP_admin_pass = var.ldap_admin_pass
    condor_control_IP = openstack_compute_instance_v2.illume-control-v2.network[0].fixed_ip_v4
    condor_pool_pass = var.condor_pass
    nfs_data1 = var.nfs_data1
    nfs_data2 = var.nfs_data2
    nfs_home = var.nfs_home
  })

  worker-quarter-template = templatefile("${path.module}/templates/worker.yml", 
  {
    partition_1 = 50
    partition_2 = 20
    partition_3 = 30
    interactive_command = "echo"
    proxy1_IP = openstack_compute_instance_v2.illume-proxy-v2[0].network[0].fixed_ip_v4
    proxy2_IP = openstack_compute_instance_v2.illume-proxy-v2[1].network[0].fixed_ip_v4
    openLDAP_IP = openstack_compute_instance_v2.illume-openLDAP-v2.network[0].fixed_ip_v4
    LDAP_admin_pass = var.ldap_admin_pass
    condor_control_IP = openstack_compute_instance_v2.illume-control-v2.network[0].fixed_ip_v4
    condor_pool_pass = var.condor_pass
    nfs_data1 = var.nfs_data1
    nfs_data2 = var.nfs_data2
    nfs_home = var.nfs_home
  })

  phpLDAPadmin-template = templatefile("${path.module}/templates/phpLDAPadmin.yml", 
  {
    openLDAP_IP = openstack_compute_instance_v2.illume-openLDAP-v2.network[0].fixed_ip_v4
  })

  control-template = templatefile("${path.module}/templates/control.yml", 
  {
    condor_pool_pass = var.condor_pass
  })

  bastion-template = templatefile("${path.module}/templates/bastion.yml", 
  {
    nfs_data1 = var.nfs_data1
    nfs_data2 = var.nfs_data2
    nfs_home = var.nfs_home
  })

  openLDAP-template = templatefile("${path.module}/templates/openLDAP.yml", 
  {
    nfs_home = var.nfs_home
  })

  ingress-template = templatefile("${path.module}/templates/ingress.yml", 
  {
    proxy1_IP = openstack_compute_instance_v2.illume-proxy-v2[0].network[0].fixed_ip_v4
    proxy2_IP = openstack_compute_instance_v2.illume-proxy-v2[1].network[0].fixed_ip_v4
    openLDAP_IP = openstack_compute_instance_v2.illume-openLDAP-v2.network[0].fixed_ip_v4
    LDAP_admin_pass = var.ldap_admin_pass
    condor_control_IP = openstack_compute_instance_v2.illume-control-v2.network[0].fixed_ip_v4
    condor_pool_pass = var.condor_pass
    nfs_data1 = var.nfs_data1
    nfs_data2 = var.nfs_data2
    nfs_home = var.nfs_home
  })

  monitor-template = templatefile("${path.module}/templates/monitor.yml",
  {
    id_endpoint = var.id_endpoint
    username = var.username
    password = var.password
    project_name = var.tenant_name
    project_id = var.project_id
    region = var.region
    domain_name = var.domain_name
    nfs_home = var.nfs_home
  })
}

# Workers mapped to information for instantiation
locals {
  worker_flavors  = {
    "1080ti"      = {
      flavor   = "c16-116gb-3400-4.1080ti"
      gpu      = true
      template = local.worker-whole-template
    }
    "interactive" = {
      flavor   = "c16-116gb-3400-4.1080ti"
      gpu      = true
      template = local.worker-interactive-template
    }
    "980"         = {
      flavor   = "c16-116gb-3400-4.980"
      gpu      = true
      template = local.worker-whole-template
    }
    "980ti"       = {
      flavor   = "c16-116gb-3400-4.980ti"
      gpu      = true
      template = local.worker-whole-template
    }
    "titanx"      = {
      flavor   = "c16-116gb-3400-4.titanx"
      gpu      = true
      template = local.worker-whole-template
    }
    "titanxp"     = {
      flavor   = "c16-116gb-3400-4.titanxp"
      gpu      = true
      template = local.worker-whole-template
    }
    "whole"       = {
      flavor   = "c16-128GB-1440-1socket"
      gpu      = false
      template = local.worker-whole-template
    }
    "half"        = {
      flavor   = "c8-64GB-720"
      gpu      = false
      template = local.worker-half-template
    }
    "quarter"      = {
      flavor   = "c4-32GB-360"
      gpu      = false
      template = local.worker-quarter-template
    }
  }

  // Build a list of all instances to deploy, with mappings like
  // "illume-worker-1080ti-01-v2": {flavor, gpu, template}
  // Flatten will merge all the lists, and merge will merge each instance map
  // into one large map (the ... at the end specifies that I want to merge a list of objects)
  worker_instances = merge(flatten([
    for name, count in var.name_counts : [
      for i in range(count) : {
        format("illume-worker-%s-%02d-v2", name, i+1) = local.worker_flavors[name]
      }
    ]
  ])...) 
}