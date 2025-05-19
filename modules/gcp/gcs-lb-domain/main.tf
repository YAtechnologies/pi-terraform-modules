# Setup custom domains and external load balancer for a given bucket  

# Enable the services needed for this module
resource "google_project_service" "services" {
  for_each           = toset(local.services)
  project            = data.google_client_config.current.project
  service            = each.value
  disable_on_destroy = false
}

# Reserve an external IP
resource "google_compute_global_address" "static_ip" {
  name   = "${var.namespace}-ip"
  labels = local.labels

  depends_on = [google_project_service.services]
}

# Create a backend service for the given bucket
resource "google_compute_backend_bucket" "backend_bucket" {
  name        = "${var.namespace}-backend"
  description = "Contains files needed by ${var.bucket_name}"
  bucket_name = var.bucket_name
  enable_cdn  = var.enable_cdn
}

# Create HTTPS certificate
resource "google_compute_managed_ssl_certificate" "ssl_cert" {
  name = "${var.namespace}-cert"
  managed {
    domains = var.domains
  }

  lifecycle {
    ignore_changes = ["expire_time"]
  }
}

# GCP URL MAP
resource "google_compute_url_map" "url_map" {
  name            = "${var.namespace}-lb"
  default_service = google_compute_backend_bucket.backend_bucket.self_link
}

# GCP target proxy
resource "google_compute_target_https_proxy" "target_proxy" {
  name             = "${var.namespace}-target-proxy"
  url_map          = google_compute_url_map.url_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_cert.self_link]
}

# GCP forwarding rule
resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name                  = "${var.namespace}-fwd-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.static_ip.address
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.target_proxy.self_link
  labels                = local.labels
}
