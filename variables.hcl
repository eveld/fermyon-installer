variable "nomad_version" {
  default = "1.3.1"
}

variable "nomad_client_nodes" {
  default = 3
}

variable "consul_version" {
  default = "1.12.2"
}

variable "consul_server_address" {
  default = "consul.container.shipyard.run"
}

variable "consul_datacenter" {
  default = "dc1"
}