job "traefik" {
  datacenters = ["dc1"]
  type        = "service"

  group "traefik" {
    count = 1

    network {
      mode = "bridge"

      port "http" {
        to = 80
      }

      port "api" {
        to = 8081
      }
    }

    service {
      name = "traefik"

      connect {
        native = true
      }
    }

    task "traefik" {
      driver = "raw_exec"

      artifact {
        source = "https://github.com/traefik/traefik/releases/download/v2.8.0-rc1/traefik_v2.8.0-rc1_${attr.kernel.name}_${attr.cpu.arch}.tar.gz"
      }

      config {
        command = "traefik"
        args = [
          "--api.dashboard=true",
          "--api.insecure=true",
          "--entrypoints.web.address=0.0.0.0:${NOMAD_PORT_http}",
          "--entrypoints.traefik.address=0.0.0.0:${NOMAD_PORT_api}",
          "--providers.nomad=true",
          "--providers.nomad.endpoint.address=http://${attr.unique.network.ip-address}:4646"
        ]
      }
    }
  }
}