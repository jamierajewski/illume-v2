data "openstack_images_image_v2" "proxy-image" {
  name        = "illume-proxy"
  most_recent = true
}

resource "openstack_compute_instance_v2" "illume-proxy-v2" {

  count = 2
  name  = format("illume-proxy-%02d-v2", count.index + 1)

  flavor_name = "c2-8GB-90"
  key_pair    = "illume-new"
  security_groups = ["illume-internal-v2", "egress"]
  depends_on = [ openstack_compute_instance_v2.illume-bastion-v2 ]
  image_id = data.openstack_images_image_v2.proxy-image.id

  # Boot device (ephemeral)
  block_device {
    uuid                  = data.openstack_images_image_v2.proxy-image.id
    source_type           = "image"
    boot_index            = 0
    destination_type      = "local"
    delete_on_termination = true
  }

  # Ephemeral storage (90GB)
  block_device {
    boot_index            = -1
    delete_on_termination = true
    destination_type      = "local"
    source_type           = "blank"
    volume_size           = 90
  }

  network {
    name = var.network
  }
  
  user_data = <<EOF
#cloud-config
mounts:
  - [ ephemeral0, /var/spool/squid ]

runcmd:
  # Do final squid configuration here now that cache space is attached
  - sudo mv /home/ubuntu/squid.conf /etc/squid/squid.conf
  - sudo chown -R squid /var/spool/squid /var/log/squid
  - sudo squid -z
  - sudo systemctl restart squid.service
  # Enable and start fail2ban
  - sudo systemctl enable fail2ban
  - sudo systemctl start fail2ban
EOF

  metadata = {
                "prometheus_node_port": 9100,
                "prometheus_node_scrape": "true"
  }
}

