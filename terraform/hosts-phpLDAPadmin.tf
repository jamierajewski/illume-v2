# Fetch the image so that we can get the ID, since the ID changes
# whenever it is rebuilt in Packer
data "openstack_images_image_v2" "phpLDAPadmin-image" {
  name        = "illume-phpLDAPadmin"
  most_recent = true
}

resource "openstack_compute_instance_v2" "illume-phpLDAPadmin-v2" {
  name = "illume-phpLDAPadmin-v2"
  flavor_id       = "11"
  key_pair        = "illume-new"
  security_groups = [
    "ssh",
    "illume-internal-v2",
  ]
  depends_on = [ openstack_compute_instance_v2.illume-openLDAP-v2]

  # Boot from volume (created from image)
  block_device {
    uuid                  = data.openstack_images_image_v2.phpLDAPadmin-image.id
    source_type           = "image"
    volume_size           = "30"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    name = var.network
  }

  user_data = local.phpLDAPadmin-template
}

