data "openstack_images_image_v2" "proxy-image" {
  name        = "illume-proxy"
  most_recent = true
}

resource "openstack_compute_instance_v2" "illume-proxy-v2" {

  count = 2
  name  = format("illume-proxy-%02d-v2", count.index + 1)

  flavor_id = "19"
  key_pair    = "illume-new"
  security_groups = [
    "illume-internal-v2"
  ]
  depends_on = [ openstack_compute_instance_v2.illume-bastion-v2 ]
  image_id = data.openstack_images_image_v2.proxy-image.id

  # boot device (ephemeral)
  block_device {
    uuid                  = data.openstack_images_image_v2.proxy-image.id
    source_type           = "image"
    boot_index            = 0
    destination_type      = "local"
    delete_on_termination = true
  }

  # Ephemeral storage (180GB)
  block_device {
    boot_index            = -1
    delete_on_termination = true
    destination_type      = "local"
    source_type           = "blank"
    volume_size           = 180
  }

  # mount ephemeral storage #0 to /var/spool/squid
  user_data = <<EOF
#cloud-config
mounts:
  - [ ephemeral0, /var/spool/squid ]
EOF


  network {
    name = var.network
  }
}

