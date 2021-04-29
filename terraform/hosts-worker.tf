resource "openstack_compute_instance_v2" "illume-workers-v2" {

  # Create each worker instance by iterating over the worker instances
  # Since it is a list, we need to project it into a map
  for_each = local.worker_instances

  name = each.key
  flavor_name = each.value.flavor
  image_id = (each.value.gpu ? data.openstack_images_image_v2.worker-image-gpu.id : data.openstack_images_image_v2.worker-image-nogpu.id)
  key_pair    = "illume-new"
  security_groups = [ "illume-internal-v2" ]
  # Depends on the control as it has to be started up first so that we can
  # automatically authenticate to it
  depends_on = [ openstack_compute_instance_v2.illume-control-v2 ]

  # Boot device (ephemeral)
  block_device {
    uuid                  = (each.value.gpu ? data.openstack_images_image_v2.worker-image-gpu.id : data.openstack_images_image_v2.worker-image-nogpu.id)
    source_type           = "image"
    boot_index            = 0
    destination_type      = "local"
    delete_on_termination = true
  }

  # Assign all ephemeral storage for this flavor, which is always the third element of our flavors
  block_device {
    boot_index            = -1
    delete_on_termination = true
    destination_type      = "local"
    source_type           = "blank"
    volume_size           = split("-", each.value.flavor)[2]
  }

  metadata = {
      "img_hide_hypervisor_id": each.value.gpu ? "true" : "false",
      "prometheus_node_port": 9100,
      "prometheus_node_scrape": "true",
      "prometheus_nvidia_port": 9445,
      "prometheus_nvidia_scrape": each.value.gpu ? "true" : "false"
  }

  network {
    name = var.network
  }

  # Use template to do setup including partitions and post-provision config 
  user_data = each.value.template
}
