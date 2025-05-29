# Export the objects created by this module

output "ip" {
  description = "The external IP address"
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

output "cloud_run_service" {
  description = "The Cloud Run proxy service"
  value       = google_cloud_run_v2_service.gcs_proxy
}

output "backend_service" {
  description = "The backend service with IAP enabled"
  value       = google_compute_backend_service.proxy_backend
}

output "service_account" {
  description = "The service account used by the proxy"
  value       = google_service_account.proxy_sa
}

output "iap_client" {
  description = "The IAP OAuth client"
  value       = google_iap_client.iap_client
  sensitive   = true
}

# Construct the HTTPS URLs
output "urls" {
  description = "The URLs of the IAP-protected GCS proxy"
  value = {
    for domain in var.domains : domain => "https://${domain}"
  }
}

output "iap_audience" {
  description = "The IAP audience value for the backend service"
  value       = local.iap_audience
}

# Export the labels used by this module
output "labels" {
  description = "The labels used by this module"
  value = {
    for key, value in local.labels : key => value
  }
}

# Reverse proxy configuration
output "reverse_proxy_config" {
  description = "Configuration for the reverse proxy functionality"
  value = {
    enabled         = var.backend_api_url != null
    backend_api_url = var.backend_api_url
    api_path_prefix = var.api_path_prefix
  }
}

# API endpoints
output "api_urls" {
  description = "The API URLs when reverse proxy is enabled"
  value = var.backend_api_url != null ? {
    for domain in var.domains : domain => "https://${domain}${var.api_path_prefix}"
  } : {}
}
