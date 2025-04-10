# Export the labels used by this module
output "labels" {
  description = "The labels used by this module"
  value = {
    for key, value in local.labels : key => value
  }
}

output "psc_consumer_fwdrule" {
  description = "Forwarding rule for PSC"
  value       = google_compute_forwarding_rule.psc_consumer_fwdrule
}

output "psc_ip_address" {
  description = "expose local address that will proxy requests to the PSC producer"
  value       = google_compute_address.psc_consumer_address
}
