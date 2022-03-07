# Provider
variable "vsphere_server" {
  type = string
  default = "192.168.1.35"
}
variable "vsphere_user" {
  type = string
  sensitive = true
}
variable "vsphere_password" {
  type = string
  sensitive = true
}

terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      version = "2.0.2"
    }
  }
}

provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "Datacenter"
}

data "vsphere_datastore" "datastore" {
  name          = "r620"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "NstrandDev"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "LANServers"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name = "ubuntutemplate"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm" {
  name             = "kube"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  wait_for_guest_net_timeout = 0

  num_cpus = 4
  memory   = 8192
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  disk {
    label = "disk0"
    size  = 40
  }
  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "kube"
        domain    = "strand.family"
      }

      network_interface {
        ipv4_address="192.168.63.200"
        ipv4_netmask=24
      }
      ipv4_gateway="192.168.63.1"
    }
  }
  provisioner "local-exec" {
    command = "cd ~/git/homelab/ansible/; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory -l kube playbooks/newserver.yaml"
  }
}
