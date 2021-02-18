# Fetch the image so that we can get the ID, since the ID changes
# whenever it is rebuilt in Packer
data "openstack_images_image_v2" "control-image" {
  name        = "illume-control"
  most_recent = true
}

resource "openstack_compute_instance_v2" "illume-control-v2" {
  name = "illume-control-v2"
  flavor_name     = "c2-8GB-90"
  key_pair        = "illume-new"
  security_groups = ["illume-internal-v2"]
  depends_on = [ openstack_compute_instance_v2.illume-proxy-v2 ]

  # Boot from volume (created from image)
  block_device {
    uuid                  = data.openstack_images_image_v2.control-image.id
    source_type           = "image"
    volume_size           = 30
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  # Assign all ephemeral storage for this flavor (90GB),
  # then split it up into partitions.
  block_device {
    boot_index            = -1
    delete_on_termination = true
    destination_type      = "local"
    source_type           = "blank"
    volume_size           = 90
  }

  network {
    name = var.network
  }

  user_data = local.control-template
}

