variable "username" {
  default = ""
}

variable "password" {
  default = ""
}

variable "tenant_id" {
  default = ""
}

variable "auth_url" {
  default = ""
}

variable "image-url" {
  default = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
}

variable "image-name" {
  default = "illume-ubuntu-focal"
}

variable "ssh_key_file" {
  default = ""
}

variable "ssh_user_name" {
  default = "ubuntu"
}

variable "floating-ip-pool" {
  default = "ext-net"
}

variable "network" {
  default = "IceCube2_network"
}

variable "local_subnet" {
  default = "192.168.254.0/24"
}

