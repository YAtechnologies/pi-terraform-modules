# Export the objects created by this module

output "ip" {
  description = "The IP address object"
  value       = google_compute_global_address.static_ip
}

output "ssl_certificate" {
  description = "The SSL certificate object"
  value       = google_compute_managed_ssl_certificate.ssl_cert
  sensitive   = true
}

output "url_map" {
  description = "The URL map object"
  value       = google_compute_url_map.url_map
}

output "target_proxy" {
  description = "The target proxy object"
  value       = google_compute_target_https_proxy.target_proxy
}

output "forwarding_rule" {
  description = "The forwarding rule object"
  value       = google_compute_global_forwarding_rule.forwarding_rule
}

# Construct the https URLs
output "urls" {
  description = "The URLs of the GCS LB domain"
  value = {
    for domain in var.domains : domain => "https://${domain}"
  }
}

# Export the labels used by this module
output "labels" {
  description = "The labels used by this module"
  value = {
    for key, value in local.labels : key => value
  }
}
