
source "openstack" "proxy" {
  flavor              = "c2-4GB-45"
  floating_ip_network = "ext-net"
  image_name          = "illume-proxy"
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
  sources = ["source.openstack.proxy"]

  provisioner "shell" {
    script = "../../bootstrap/squid/squid.sh"
  }

  provisioner "file" {
    destination = "/home/ubuntu/squid.conf"
    source      = "../../bootstrap/squid/squid.conf"
  }

}
