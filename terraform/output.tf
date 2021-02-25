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

output "illume-worker-1080ti-addresses" {
  value = openstack_compute_instance_v2.illume-worker-1080ti-v2.*.network.0.fixed_ip_v4
}

output "illume-worker-interactive-addresses" {
  value = openstack_compute_instance_v2.illume-worker-interactive-v2.*.network.0.fixed_ip_v4
}

output "illume-worker-titanx-addresses" {
  value = openstack_compute_instance_v2.illume-worker-titanx-v2.*.network.0.fixed_ip_v4
}

output "illume-worker-titanxp-addresses" {
  value = openstack_compute_instance_v2.illume-worker-titanxp-v2.*.network.0.fixed_ip_v4
}

output "illume-worker-980-addresses" {
  value = openstack_compute_instance_v2.illume-worker-980-v2.*.network.0.fixed_ip_v4
}

output "illume-worker-980ti-addresses" {
  value = openstack_compute_instance_v2.illume-worker-980ti-v2.*.network.0.fixed_ip_v4
}

output "illume-worker-nogpu-quarter-addresses" {
  value = openstack_compute_instance_v2.illume-worker-nogpu-quarter-v2.*.network.0.fixed_ip_v4
}

output "illume-worker-nogpu-half-addresses" {
  value = openstack_compute_instance_v2.illume-worker-nogpu-half-v2.*.network.0.fixed_ip_v4
}

output "illume-worker-nogpu-whole-addresses" {
  value = openstack_compute_instance_v2.illume-worker-nogpu-whole-v2.*.network.0.fixed_ip_v4
}

output "illume-ingress-addresses" {
  value = openstack_compute_instance_v2.illume-ingress-v2.*.network.0.fixed_ip_v4
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