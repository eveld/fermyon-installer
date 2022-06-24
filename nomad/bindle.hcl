variable "domain" {
  type        = string
  default     = "local.fermyon.link"
  description = "hostname"
}

variable "bindle_version" {
  type        = string
  default     = "v0.8.0"
  description = "Bindle version"
}

job "bindle" {
  datacenters = ["dc1"]
  type        = "service"

  group "bindle" {
    count = 1

    network {
      mode = "bridge"

      port "http" {
        to = 8080
      }
    }

    service {
      name     = "bindle"
      port     = "http"
      provider = "nomad"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.bindle.rule=Host(`bindle.${var.domain}`)",
      ]
    }

    task "bindle" {
      driver = "raw_exec"

      artifact {
        source = "https://raw.githubusercontent.com/fermyon/installer/9fca2d7b641440cef0f75d38ace9cd3128b5a8a3/local/bindle/bindle-server"
      }

      env {
        RUST_LOG = "error,bindle=debug"
      }

      config {
        command = "bindle-server"
        args = [
          "--unauthenticated",
          "--address", "0.0.0.0:8080",
          "--directory", "${NOMAD_TASK_DIR}",
        ]
      }
    }
  }
}