
source "openstack" "worker_gpu" {
  flavor              = "c4-29gb-850-1.1080ti"
  floating_ip_network = "ext-net"
  force_delete        = true
  image_name          = "illume-worker-gpu"
  metadata = {
    img_hide_hypervisor_id = "true"
  }
  networks        = ["ddbdc508-53dd-4a4f-8be7-c6555fefda62"]
  reuse_ips       = true
  security_groups = ["ssh", "egress"]
  source_image_filter {
    most_recent = true
  }
  source_image_name = "illume-worker-nogpu"
  ssh_username      = "ubuntu"
}

build {
  sources = ["source.openstack.worker_gpu"]

  provisioner "file" {
    destination = "/home/ubuntu/containers.conf"
    source      = "../../bootstrap/cuda/containers.conf"
  }

  provisioner "shell" {
    expect_disconnect = true
    script            = "../../bootstrap/cuda/cuda.sh"
  }

  provisioner "shell" {
    expect_disconnect = true
    script            = "../../bootstrap/cuda/cuda-container.sh"
  }

  provisioner "shell" {
    script = "../../bootstrap/monitoring/nvidia-exporter.sh"
  }

}
