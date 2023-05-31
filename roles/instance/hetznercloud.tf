terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
  required_version = ">= 0.13"
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}

# Get SSH key data
data "hcloud_ssh_key" "ssh_key" {
  name = "rsa-key-20220418"
}

# Create a server
resource "hcloud_server" "ubuntu20" {
  count       = var.server_count
  name        = "${var.host_group_name}-server-${count.index + 1}"
  image       = "ubuntu-20.04"
  server_type = var.type
  ssh_keys    = [data.hcloud_ssh_key.ssh_key.id]
    public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
}

resource "hcloud_firewall" "myfirewall" {
  depends_on  = [null_resource.run_playbook]
  name = var.host_group_name
  rule {
    direction  = "in"
    protocol   = "icmp"
    source_ips = var.source_ips
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = var.ssh_port
    source_ips = var.source_default
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = var.tls_port
    source_ips = var.source_default
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = var.zabbix_agent_port
    source_ips = var.source_ips
  }
}

locals {
  server_ips = hcloud_server.ubuntu20[*].ipv4_address
}

resource "null_resource" "update_hosts_file_add_group" {
  provisioner "local-exec" {
    command = "echo '\n[${var.host_group_name}]' >> ${path.module}/hosts"
  }
}

resource "null_resource" "update_hosts_file" {
  depends_on  = [null_resource.update_hosts_file_add_group]
  count = var.server_count

  provisioner "local-exec" {
    command  = "echo '${hcloud_server.ubuntu20[count.index].name} ansible_host=${local.server_ips[count.index]}' >> ${path.module}/hosts"
  }
}

resource "hcloud_firewall_attachment" "attach_in_firewall" {
  count       = var.server_count
  depends_on  = [null_resource.run_playbook]
  firewall_id = hcloud_firewall.myfirewall.id
  server_ids  = [hcloud_server.ubuntu20[count.index].id]
}

resource "null_resource" "run_playbook" {
    depends_on = [
    null_resource.update_hosts_file_add_group,
    null_resource.update_hosts_file
  ]

  provisioner "local-exec" {
    command = "ansible-playbook --extra-vars 'host_group_name=${var.host_group_name}' --ask-vault-pass instancesterraform.yml"
  }
}

output "server_ip_ubuntu20" {
  value = hcloud_server.ubuntu20[*].ipv4_address
}

resource "null_resource" "run_ansible_destroy" {
  provisioner "local-exec" {
    when    = destroy
    command = "ansible-playbook  --ask-vault-pass destroy.yml"
  }
}
