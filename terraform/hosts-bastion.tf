# Fetch the image so that we can get the ID, since the ID changes
# whenever it is rebuilt in Packer
data "openstack_images_image_v2" "bastion-image" {
  name        = "illume-bastion"
  most_recent = true
}

# Create a small boot device as the home directory for the ubuntu user is under the NFS
resource "openstack_blockstorage_volume_v3" "bastion-volume" {
  name = "bastion-volume"
  size = "120"
  image_id = data.openstack_images_image_v2.bastion-image.id
}

resource "openstack_compute_instance_v2" "illume-bastion-v2" {
  name = format("%s%s", (var.testing == true ? "TEST-" : ""), "illume-bastion-v2")
  flavor_name     = "p2-8gb"
  key_pair        = "illume-new"
  security_groups = ["illume-bastion", format("%s%s", "illume-internal", (var.testing == true ? "" : "-v2"))]

  # boot from volume (created from image)
  block_device {
    uuid                  = openstack_blockstorage_volume_v3.bastion-volume.id
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  metadata = {
                "prometheus_node_port": 9100,
                "prometheus_node_scrape": "true"
  }

  network {
    name = var.network
  }
  
  user_data = local.bastion-template
}

# Get the reference to the floating IP we want to use...
resource "openstack_networking_floatingip_v2" "illume-bastion-v2" {
  pool = var.floating_ip_pool
  address = var.bastion_ip
}

# ...and attach it
resource "openstack_compute_floatingip_associate_v2" "illume-bastion-v2" {
  floating_ip = openstack_networking_floatingip_v2.illume-bastion-v2.address
  instance_id = openstack_compute_instance_v2.illume-bastion-v2.id
}