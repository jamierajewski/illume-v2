# Fetch the image so that we can get the ID, since the ID changes
# whenever it is rebuilt in Packer
data "openstack_images_image_v2" "openLDAP-image" {
  name        = "illume-openLDAP"
  most_recent = true
}

# Create a named volume so that we can detach and reattach for maintenance
# This contains the LDAP database, so we want to keep it safe
resource "openstack_blockstorage_volume_v3" "openLDAP-volume" {
  name = "openLDAP-volume"
  size = "30"
  image_id = data.openstack_images_image_v2.openLDAP-image.id
}

resource "openstack_compute_instance_v2" "illume-openLDAP-v2" {
  name = "illume-openLDAP-v2"
  flavor_id       = "11"
  key_pair        = "illume-new"
  security_groups = [
    "illume-internal-v2",
  ]
  depends_on = [
    openstack_compute_instance_v2.illume-bastion-v2
  ]

  # Boot from volume (created from image)
  block_device {
    uuid                  = openstack_blockstorage_volume_v3.openLDAP-volume.id
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = false
  }

  network {
    name = var.network
  }
}
