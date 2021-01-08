resource "openstack_images_image_v2" "illume-ubuntu" {
  name             = var.image-name
  image_source_url = var.image-url
  container_format = "bare"
  disk_format      = "qcow2"
  min_disk_gb      = 1

  properties = {
    img_hide_hypervisor_id = "true"
  }
}

