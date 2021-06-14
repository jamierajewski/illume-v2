# Fetch the image so that we can get the ID, since the ID changes
# whenever it is rebuilt in Packer
data "openstack_images_image_v2" "monitor-image" {
  name        = "illume-monitor"
  most_recent = true
}

resource "openstack_blockstorage_volume_v3" "monitor-volume" {
  name = "monitor-volume"
  size = "30"
  image_id = data.openstack_images_image_v2.monitor-image.id
}

resource "openstack_compute_instance_v2" "illume-monitor-v2" {
  name = "illume-monitor-v2"
  flavor_name     = "c2-4GB-45"
  key_pair        = "illume-new"
  security_groups = ["illume-internal-v2"]

  # Boot from volume (created from image)
  block_device {
    uuid                  = openstack_blockstorage_volume_v3.monitor-volume.id
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  # Assign all ephemeral storage for this flavor (45GB),
  # then split it up into partitions.
  # Right now, this isn't used for anything since prometheus data is stored on NFS
  block_device {
    boot_index            = -1
    delete_on_termination = true
    destination_type      = "local"
    source_type           = "blank"
    volume_size           = 45
  }

  network {
    name = var.network
  }

  user_data = local.monitor-template
}

