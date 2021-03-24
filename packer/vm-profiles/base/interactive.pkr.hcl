
source "openstack" "interactive" {
  flavor              = "c2-4GB-45"
  floating_ip_network = "ext-net"
  image_name          = "illume-interactive"
  networks            = ["ddbdc508-53dd-4a4f-8be7-c6555fefda62"]
  reuse_ips           = true
  security_groups     = ["ssh", "egress"]
  source_image_filter {
    most_recent = true
  }
  source_image_name = "illume-non-interactive"
  ssh_username      = "ubuntu"
}

build {
  sources = ["source.openstack.interactive"]

  provisioner "file" {
    destination = "/home/ubuntu/01-illume-welcome"
    source      = "../../bootstrap/welcome/01-illume-welcome"
  }

  provisioner "shell" {
    script = "../../bootstrap/welcome/welcome.sh"
  }

  provisioner "shell" {
    script = "../../bootstrap/cvmfs/cvmfs.sh"
  }

  provisioner "shell" {
    expect_disconnect = true
    script            = "../../bootstrap/tools/user-tools.sh"
  }

  provisioner "file" {
    destination = "/home/ubuntu/default.local"
    source      = "../../bootstrap/cvmfs/default.local"
  }

  provisioner "shell" {
    script = "../../bootstrap/podman/podman.sh"
  }

  provisioner "shell" {
    script = "../../bootstrap/singularity/singularity.sh"
  }

}
