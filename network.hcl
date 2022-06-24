//
// The virtual network all components are placed on
//
network "dc1" {
  subnet = "10.5.0.0/16"
}

// nomad_ingress "ingress" {
//   cluster = "nomad_cluster.dc1"

//   job   = "ingress"
//   group = "ingress"
//   task  = "ingress"

//   port {
//     local  = 80
//     remote = "http"
//     host   = 80
//   }

//   network {
//     name = "network.dc1"
//   }
// }

nomad_ingress "traefik" {
  cluster = "nomad_cluster.dc1"

  job   = "traefik"
  group = "traefik"
  task  = "traefik"

  port {
    local  = 80
    remote = "http"
    host   = 80
  }

  network {
    name = "network.dc1"
  }
}

nomad_ingress "traefik-api" {
  cluster = "nomad_cluster.dc1"

  job   = "traefik"
  group = "traefik"
  task  = "traefik"

  port {
    local  = 8081
    remote = "api"
    host   = 8081
  }

  network {
    name = "network.dc1"
  }
}