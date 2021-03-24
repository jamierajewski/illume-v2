
variable "ssh_key_source" {
  type    = string
  default = "${env("SSH_KEY_SOURCE")}"
}

source "openstack" "non_interactive" {
  flavor              = "c2-4GB-45"
  floating_ip_network = "ext-net"
  image_name          = "illume-non-interactive"
  networks            = ["ddbdc508-53dd-4a4f-8be7-c6555fefda62"]
  reuse_ips           = true
  security_groups     = ["ssh", "egress"]
  source_image_name   = "Ubuntu-20.04.1-Focal-x64-2020-10"
  ssh_username        = "ubuntu"
}

build {
  sources = ["source.openstack.non_interactive"]

  provisioner "file" {
    destination = "/home/ubuntu/.ssh/illume_key"
    source      = "${var.ssh_key_source}"
  }

  provisioner "shell" {
    inline = ["chmod og-rwx /home/ubuntu/.ssh/illume_key"]
  }

  provisioner "shell" {
    inline = ["sudo apt-get update -y", "sudo apt-get dist-upgrade -y"]
  }

  provisioner "shell" {
    expect_disconnect = true
    script            = "../../bootstrap/common/common.sh"
  }

  provisioner "shell" {
    script = "../../bootstrap/monitoring/node-exporter.sh"
  }

}
