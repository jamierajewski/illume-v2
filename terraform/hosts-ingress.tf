data "openstack_images_image_v2" "ingress-image" {
  name        = "illume-ingress"
  most_recent = true
}

resource "openstack_blockstorage_volume_v3" "ingress-volume" {
  name = "ingress-volume"
  size = "30"
  image_id = data.openstack_images_image_v2.ingress-image.id
}

resource "openstack_compute_instance_v2" "illume-ingress-v2" {

  name  = "illume-ingress-v2"
  flavor_name = "c10-128GB-1440"
  key_pair    = "illume-new"
  security_groups = [ "illume-internal-v2", "illume" ]
  depends_on = [ openstack_compute_instance_v2.illume-proxy-v2 ]

  # boot device (ephemeral)
  # Use a small size as we will mount the NFS with the larger storage
  block_device {
    uuid                  = openstack_blockstorage_volume_v3.ingress-volume.id
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = false
  }

  # Check out this article for creating a shared dir for podman images:
  # https://www.redhat.com/sysadmin/image-stores-podman

  # Assign all ephemeral storage for this flavor (1440GB),
  # then split it up into partitions.
  block_device {
    boot_index            = -1
    delete_on_termination = true
    destination_type      = "local"
    source_type           = "blank"
    volume_size           = 1440
  }

  metadata = {
                "prometheus_node_port": 9100,
                "prometheus_node_scrape": "true"
  }
  
  network {
    name = var.network
  }

  user_data = local.ingress-template
}

# Attach a floating IP to this instance
resource "openstack_networking_floatingip_v2" "illume-ingress-v2" {
  pool = var.floating_ip_pool
}

resource "openstack_compute_floatingip_associate_v2" "illume-ingress-v2" {
  floating_ip = openstack_networking_floatingip_v2.illume-ingress-v2.address
  instance_id = openstack_compute_instance_v2.illume-ingress-v2.id
}

