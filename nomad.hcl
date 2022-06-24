//
// Configuration for the spin task driver
//
template "nomad_plugin_config" {
  source      = <<-EOT
  plugin "spin" {
    config {
    }
  }
  EOT
  destination = "${data("nomad")}/plugin.hcl"
}

// TBD
template "nomad_allow_config" {
  source      = <<-EOT
  client {
    options = {
      "user.denylist" = ""
    }
  }
  EOT
  destination = "${data("nomad")}/allow.hcl"
}

//
// Configuration for the consul agent running on the nomad nodes
//
template "consul_agent_config" {
  source      = <<-EOT
  datacenter = "#{{ .Vars.consul_datacenter }}"
  retry_join = ["#{{ .Vars.consul_server_address }}"]
  EOT
  destination = "${data("consul")}/agent.hcl"

  vars = {
    consul_datacenter     = var.consul_datacenter
    consul_server_address = var.consul_server_address
  }
}

template "download_spin" {
  source      = <<-EOT
  curl -L -o spin.tar.gz https://github.com/fermyon/spin/releases/download/v0.3.0/spin-v0.3.0-linux-amd64.tar.gz
  tar xzf spin.tar.gz
  mv spin /files/
  EOT
  destination = "${data("nomad")}/download_spin.sh"
}

exec_remote "download_spin" {
  depends_on = ["template.download_spin"]

  image {
    name = "shipyardrun/hashicorp-tools:v0.9.0"
  }

  network {
    name = "network.dc1"
  }

  cmd = "/bin/bash"
  args = [
    "/files/download_spin.sh"
  ]

  volume {
    source      = "${data("nomad")}"
    destination = "/files"
  }
}

//
// The nomad cluster
//
nomad_cluster "dc1" {
  depends_on = ["exec_remote.download_spin", "template.consul_agent_config"]

  version      = var.nomad_version
  client_nodes = var.nomad_client_nodes

  consul_config = "${data("consul")}/agent.hcl"

  network {
    name = "network.dc1"
  }

  // volume {
  //   source      = "${data("nomad")}/allow.hcl"
  //   destination = "/etc/nomad.d/allow.hcl"
  // }

  // volume {
  //   source      = "${data("nomad")}/plugin.hcl"
  //   destination = "/etc/nomad.d/plugin.hcl"
  // }

  volume {
    source      = "${data("nomad")}/spin"
    destination = "/usr/bin/spin"
  }

  // volume {
  //   source      = "${file_dir()}/nomad/plugins/spin"
  //   destination = "/var/lib/nomad/plugins/spin"
  // }
}