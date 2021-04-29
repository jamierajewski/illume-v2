output "bastion-address" {
  value = openstack_compute_instance_v2.illume-bastion-v2.network[0].fixed_ip_v4
}

output "bastion-address-public" {
  value = openstack_networking_floatingip_v2.illume-bastion-v2.address
}

output "illume-proxy-addresses" {
  value = openstack_compute_instance_v2.illume-proxy-v2.*.network.0.fixed_ip_v4
}

output "illume-control-addresses" {
  value = openstack_compute_instance_v2.illume-control-v2.*.network.0.fixed_ip_v4
}

output "illume-openLDAP-addresses" {
  value = openstack_compute_instance_v2.illume-openLDAP-v2.*.network.0.fixed_ip_v4
}

output "illume-phpLDAPadmin-addresses" {
  value = openstack_compute_instance_v2.illume-phpLDAPadmin-v2.*.network.0.fixed_ip_v4
}

output "illume-worker-addresses" {
  value = {
    for k, v in openstack_compute_instance_v2.illume-workers-v2: k => v.network.0.fixed_ip_v4
  }
}

output "illume-ingress-addresses" {
  value = openstack_compute_instance_v2.illume-ingress-v2.*.network.0.fixed_ip_v4
}

output "illume-monitor-addresses" {
  value = openstack_compute_instance_v2.illume-monitor-v2.*.network.0.fixed_ip_v4
}

output "illume-ingress-addresses-public" {
  value = openstack_networking_floatingip_v2.illume-ingress-v2.*.address
}

output "ssh-key-file" {
  value = var.ssh_key_file
}

output "ssh-username" {
  value = var.ssh_user_name
}