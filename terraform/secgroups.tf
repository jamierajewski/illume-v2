
resource "openstack_networking_secgroup_v2" "egress-secgroup" {
  name        = "egress-secgroup"
  description = "Allow all outbound traffic"
}

resource "openstack_networking_secgroup_rule_v2" "egress-secgroup-rule-1"{
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.egress-secgroup.id
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "egress-secgroup-rule-2"{
  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.egress-secgroup.id
  remote_ip_prefix  = "::/0"
}

# ----------------------------# 

resource "openstack_networking_secgroup_v2" "ingress-secgroup" {
  name        = "ingress-secgroup"
  description = "Allow incoming traffic on ports 22, 80, 443"
}

resource "openstack_networking_secgroup_rule_v2" "ingress-secgroup-rule-1"{
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  security_group_id = openstack_networking_secgroup_v2.ingress-secgroup.id
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "ingress-secgroup-rule-2"{
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  security_group_id = openstack_networking_secgroup_v2.ingress-secgroup.id
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "ingress-secgroup-rule-3"{
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  security_group_id = openstack_networking_secgroup_v2.ingress-secgroup.id
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "ingress-secgroup-rule-4"{
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  security_group_id = openstack_networking_secgroup_v2.ingress-secgroup.id
  remote_ip_prefix  = "0.0.0.0/0"
}

# ----------------------------# 

resource "openstack_networking_secgroup_v2" "internal-secgroup" {
  name        = "internal-secgroup"
  description = "Allow all incoming local traffic"
}

resource "openstack_networking_secgroup_rule_v2" "internal-secgroup-rule-1"{
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.internal-secgroup.id
  remote_ip_prefix  = var.local_subnet
}

# ----------------------------# 

resource "openstack_networking_secgroup_v2" "nfs-secgroup" {
  name        = "nfs-secgroup"
  description = "Allow NFS traffic"
}

resource "openstack_networking_secgroup_rule_v2" "nfs-secgroup-rule-1"{
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 111
  port_range_max    = 111
  security_group_id = openstack_networking_secgroup_v2.nfs-secgroup.id
  remote_ip_prefix  = var.local_subnet
}

resource "openstack_networking_secgroup_rule_v2" "nfs-secgroup-rule-2"{
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 662
  port_range_max    = 662
  security_group_id = openstack_networking_secgroup_v2.nfs-secgroup.id
  remote_ip_prefix  = var.local_subnet
}

resource "openstack_networking_secgroup_rule_v2" "nfs-secgroup-rule-3"{
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2049
  port_range_max    = 2049
  security_group_id = openstack_networking_secgroup_v2.nfs-secgroup.id
  remote_ip_prefix  = var.local_subnet
}

resource "openstack_networking_secgroup_rule_v2" "nfs-secgroup-rule-4"{
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 38465
  port_range_max    = 38467
  security_group_id = openstack_networking_secgroup_v2.nfs-secgroup.id
  remote_ip_prefix  = var.local_subnet
}

resource "openstack_networking_secgroup_rule_v2" "nfs-secgroup-rule-5"{
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 111
  port_range_max    = 111
  security_group_id = openstack_networking_secgroup_v2.nfs-secgroup.id
  remote_ip_prefix  = var.local_subnet
}
