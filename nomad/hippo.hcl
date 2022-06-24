variable "domain" {
  type        = string
  default     = "local.fermyon.link"
  description = "hostname"
}

variable "hippo_version" {
  type        = string
  default     = "v0.17.0"
  description = "Hippo version"
}

job "hippo" {
  datacenters = ["dc1"]
  type        = "service"

  group "hippo" {
    network {
      mode = "bridge"

      port "http" {
        to = 5309
      }
    }

    service {
      name     = "hippo"
      port     = "http"
      provider = "nomad"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.hippo.rule=Host(`hippo.${var.domain}`)",
      ]
    }

    task "hippo" {
      driver = "raw_exec"

      artifact {
        source = "https://github.com/deislabs/hippo/releases/download/${var.hippo_version}/hippo-server-linux-x64.tar.gz"
      }

      artifact {
        source      = "https://gist.githubusercontent.com/bacongobbler/48dc7b01aa99fa4b893eeb6b62f8cd27/raw/fb4dae8f42bc6aea22b2566084d01fa0de845e7c/styles.css"
        destination = "local/linux-x64/wwwroot/"
      }

      artifact {
        source      = "https://gist.githubusercontent.com/bacongobbler/48dc7b01aa99fa4b893eeb6b62f8cd27/raw/fb4dae8f42bc6aea22b2566084d01fa0de845e7c/logo.svg"
        destination = "local/linux-x64/wwwroot/assets/"
      }

      artifact {
        source      = "https://gist.githubusercontent.com/bacongobbler/48dc7b01aa99fa4b893eeb6b62f8cd27/raw/fb4dae8f42bc6aea22b2566084d01fa0de845e7c/config.json"
        destination = "local/linux-x64/wwwroot/assets/"
      }

      artifact {
        source      = "https://www.fermyon.com/favicon.ico"
        destination = "local/linux-x64/wwwroot/assets/"
      }

      template {
        data        = <<-EOT
        {{- range $index, $service := nomadService "bindle" }}
        {{- if eq $index 0}}
        Bindle__Url=http://{{ $service.Address }}:{{ $service.Port }}/v1
        {{- end }}
        {{- end }}
        EOT
        destination = "secrets/services.env"
        env         = true
      }

      env {
        ASPNETCORE_ENVIRONMENT = "Development"
        Hippo__PlatformDomain  = var.domain
        Scheduler__Driver      = "nomad"
        Nomad__Url             = "http://${attr.unique.network.ip-address}:4646/v1"
        Nomad__Driver          = "raw_exec"

        Database__Driver            = "sqlite"
        ConnectionStrings__Database = "Data Source=hippo.db;Cache=Shared"

        Jwt__Key      = "ceci n'est pas une jeton"
        Jwt__Issuer   = "localhost"
        Jwt__Audience = "localhost"

        Kestrel__Endpoints__Https__Url = "http://0.0.0.0:5309"
      }

      config {
        command = "bash"
        args    = ["-c", "cd local/linux-x64 && ./Hippo.Web"]
      }
    }
  }
}