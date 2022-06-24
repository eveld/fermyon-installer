output "NOMAD_ADDR" {
  value = cluster_api("nomad_cluster.dc1")
}

output "CONSUL_HTTP_ADDR" {
  value = "http://localhost:8500"
}

output "TRAEFIK_DASHBOARD" {
  value = "http://localhost:8081/dashboard"
}