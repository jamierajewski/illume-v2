resource "openstack_compute_instance_v2" "illume-worker-980-v2" {

  count = 0
  name  = format("illume-worker-980-%02d-v2", count.index + 1)

  flavor_name = "c16-116gb-3400-4.980"
  image_id = data.openstack_images_image_v2.worker-image-gpu.id
  key_pair    = "illume-new"
  security_groups = [ "illume-internal-v2" ]
  depends_on = [ openstack_compute_instance_v2.illume-control-v2 ]

  # Boot device (ephemeral)
  block_device {
    uuid                  = data.openstack_images_image_v2.worker-image-gpu.id
    source_type           = "image"
    boot_index            = 0
    destination_type      = "local"
    delete_on_termination = true
  }

  # Assign all ephemeral storage for this flavor (3400GB),
  # then split it up into partitions.
  block_device {
    boot_index            = -1
    delete_on_termination = true
    destination_type      = "local"
    source_type           = "blank"
    volume_size           = 3400
  }

  metadata = {
      "img_hide_hypervisor_id": "true",
      "prometheus_node_port": 9100,
      "prometheus_node_scrape": "true",
      "prometheus_nvidia_port": 9445,
      "prometheus_nvidia_scrape": "true"
  }
  
  network {
    name = var.network
  }

  # Use template to do setup including partitions and post-provision config 
  user_data = local.worker-whole-template
}
