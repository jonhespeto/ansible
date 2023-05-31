# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
variable "hcloud_token" {}

variable "host_group_name" {
  description = "Enter the name of the servers"
  type        = string
}

variable "type" {
  description = "The type of the resource"
  type        = string
}

variable "server_count" {
  description = "Enter the number of servers you want"
  type        = number
}

variable "source_ips" {
  type    = list
}

variable "source_default" {
  type    = list
}

variable "ssh_port" {
  type    = string
}

variable "tls_port" {
  type    = string
}

variable "zabbix_agent_port" {
  type    = string
}
