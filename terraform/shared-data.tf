data "openstack_images_image_v2" "worker-image-gpu" {
  name        = "illume-worker-gpu"
  most_recent = true
}

data "openstack_images_image_v2" "worker-image-nogpu" {
  name        = "illume-worker-nogpu"
  most_recent = true
}
