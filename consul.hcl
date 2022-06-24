//
// Configuration for the consul server
//
template "consul_server_config" {
  source      = <<-EOT
  data_dir  = "/tmp/"
  log_level = "DEBUG"

  datacenter = "#{{ .Vars.consul_datacenter }}"

  server = true

  bootstrap_expect = 1
  ui               = true

  bind_addr   = "0.0.0.0"
  client_addr = "0.0.0.0"

  ports {
    grpc = 8502
  }

  connect {
    enabled = true
  }
  EOT
  destination = "${data("consul")}/server.hcl"

  vars = {
    consul_datacenter = var.consul_datacenter
  }
}

// 
// The consul server
//
container "consul" {
  depends_on = ["template.consul_server_config"]

  image {
    name = "consul:${var.consul_version}"
  }

  command = ["consul", "agent", "-config-file=/config/server.hcl"]

  volume {
    source      = "${data("consul")}/server.hcl"
    destination = "/config/server.hcl"
  }

  network {
    name = "network.dc1"
  }

  port {
    local  = 8500
    remote = 8500
    host   = 8500
  }
}