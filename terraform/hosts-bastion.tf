# Fetch the image so that we can get the ID, since the ID changes
# whenever it is rebuilt in Packer
data "openstack_images_image_v2" "bastion-image" {
  name        = "illume-bastion"
  most_recent = true
}

resource "openstack_compute_instance_v2" "illume-bastion-v2" {
  name = "illume-bastion-v2"
  flavor_name     = "p2-8gb"
  key_pair        = "illume-new"
  security_groups = ["illume-bastion", "illume-internal-v2"]

  # boot from volume (created from image)
  block_device {
    uuid                  = data.openstack_images_image_v2.bastion-image.id
    source_type           = "image"
    volume_size           = "120"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = false
  }

  network {
    name = var.network
  }
}

resource "openstack_networking_floatingip_v2" "illume-bastion-v2" {
  pool = var.floating_ip_pool
}

resource "openstack_compute_floatingip_associate_v2" "illume-bastion-v2" {
  floating_ip = openstack_networking_floatingip_v2.illume-bastion-v2.address
  instance_id = openstack_compute_instance_v2.illume-bastion-v2.id
}
