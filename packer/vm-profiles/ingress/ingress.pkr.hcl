
source "openstack" "ingress" {
  flavor              = "c2-4GB-45"
  floating_ip_network = "ext-net"
  image_name          = "illume-ingress"
  networks            = ["ddbdc508-53dd-4a4f-8be7-c6555fefda62"]
  reuse_ips           = true
  security_groups     = ["ssh", "egress"]
  source_image_filter {
    most_recent = true
  }
  source_image_name = "illume-interactive"
  ssh_username      = "ubuntu"
}

build {
  sources = ["source.openstack.ingress"]

  provisioner "shell" {
    script = "../../bootstrap/ldap/ldap-client.sh"
  }

  provisioner "shell" {
    inline = ["sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config"]
  }

  provisioner "shell" {
    script = "../../bootstrap/htcondor/htcondor.sh"
  }

  provisioner "file" {
    destination = "/home/ubuntu/condor_config.local"
    source      = "../../bootstrap/htcondor/local_configs/submit.local"
  }

  provisioner "shell" {
    inline = ["sudo mv /home/ubuntu/condor_config.local /etc/condor/condor_config.local"]
  }

}
