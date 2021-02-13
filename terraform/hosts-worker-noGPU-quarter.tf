resource "openstack_compute_instance_v2" "illume-worker-nogpu-quarter-v2" {

  count = 0
  name  = format("illume-worker-nogpu-quarter-%02d-v2", count.index + 1)

  flavor_name = "c4-32GB-360"
  image_id = data.openstack_images_image_v2.worker-image-nogpu.id
  key_pair    = "illume-new"
  security_groups = [ "illume-internal-v2" ]
  # Depends on the control as it has to be started up first so that we can
  # automatically authenticate to it
  depends_on = [ openstack_compute_instance_v2.illume-control-v2 ]

  # boot device (ephemeral)
  block_device {
    uuid                  = data.openstack_images_image_v2.worker-image-nogpu.id
    source_type           = "image"
    boot_index            = 0
    destination_type      = "local"
    delete_on_termination = true
  }

  # assign all ephemeral storage for this flavor (360GB),
  # then split it up into partitions.

  block_device {
    boot_index            = -1
    delete_on_termination = true
    destination_type      = "local"
    source_type           = "blank"
    volume_size           = 360
  }

  network {
    name = var.network
  }

  # Use template to do setup including partitions and post-provision config 
  user_data = local.worker-quarter-template
}
