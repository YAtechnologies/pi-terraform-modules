# Export the labels used by this module
output "labels" {
  description = "The labels used by this module"
  value = {
    for key, value in local.labels : key => value
  }
}

output "vpc_network" {
  description = "The vpc network object"
  value       = google_compute_network.vpc_network
}

output "cloud_run_access_connector" {
  description = "The vpc access connector for cloud run network object"
  value       = google_vpc_access_connector.cloud_run_access_connector
}

output "untrusted_subnet_router" {
  description = "The router object for the untrusted/public vpc network segement"
  value       = google_compute_router.untrusted_subnet_router
}

output "untrusted_subnet_router_nat" {
  description = "The router nat object the untrusted/public vpc network segement"
  value       = google_compute_router_nat.untrusted_subnet_router_nat
}

output "public_subnet" {
  description = "The vpc public subnet object"
  value       = google_compute_subnetwork.public_subnet
}

output "untrusted_subnet" {
  description = "The vpc untrusted subnet object"
  value       = google_compute_subnetwork.untrusted_subnet
}

output "isolated_subnet" {
  description = "The vpc isolated subnet object"
  value       = google_compute_subnetwork.isolated_subnet
}

output "vpc_connector_subnet" {
  description = "The vpc connector subnet object"
  value       = google_compute_subnetwork.vpc_connector_subnet
}
