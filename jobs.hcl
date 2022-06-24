// exec_remote "consul_central_config" {
//   depends_on = ["container.consul"]

//   image {
//     name = "consul:${var.consul_version}"
//   }

//   network {
//     name = "network.dc1"
//   }

//   cmd               = "/bin/sh"
//   working_directory = "/config"
//   args = [
//     "set_defaults.sh"
//   ]

//   volume {
//     source      = "${file_dir()}/consul"
//     destination = "/config"
//   }


//   env {
//     key   = "CONSUL_HTTP_ADDR"
//     value = "http://${var.consul_server_address}:8500"
//   }
// }

nomad_job "platform" {
  cluster = "nomad_cluster.dc1"
  paths = [
    "nomad/bindle.hcl",
    "nomad/hippo.hcl",
    "nomad/traefik.hcl"
  ]
}

// nomad_job "ingress" {
//   depends_on = ["consul_central_config", "nomad_job.platform"]

//   cluster = "nomad_cluster.dc1"
//   paths = [
//     "nomad/ingress.hcl"
//   ]
// }