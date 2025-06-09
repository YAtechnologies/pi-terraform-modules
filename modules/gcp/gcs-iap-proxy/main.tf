# Setup IAP-protected GCS proxy with external load balancer

# Enable required services
resource "google_project_service" "services" {
  for_each           = toset(local.services)
  project            = data.google_client_config.current.project
  service            = each.value
  disable_on_destroy = false
}

# Service account for the Cloud Run proxy
resource "google_service_account" "proxy_sa" {
  account_id   = "${var.namespace}-gcs-proxy"
  display_name = "GCS IAP Proxy Service Account"
  description  = "Service account for the GCS IAP proxy service"
}

# Grant storage access to the service account
resource "google_storage_bucket_iam_member" "proxy_storage_access" {
  count  = var.bucket_name != "" ? 1 : 0
  bucket = var.bucket_name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.proxy_sa.email}"
}

# Cloud Run service for GCS proxy
resource "google_cloud_run_v2_service" "gcs_proxy" {
  name     = "${var.namespace}-gcs-proxy"
  location = var.region

  deletion_protection = false

  template {
    service_account = google_service_account.proxy_sa.email

    containers {
      image = var.proxy_image

      # Core environment variables
      dynamic "env" {
        for_each = var.bucket_name != "" ? [1] : []
        content {
          name  = "GCS_BUCKET"
          value = var.bucket_name
        }
      }

      # SPA configuration
      env {
        name  = "SPA_MODE"
        value = var.spa_mode ? "true" : "false"
      }

      env {
        name  = "SPA_FALLBACK_FILE"
        value = var.spa_fallback_file
      }

      # Compression configuration
      env {
        name  = "ENABLE_COMPRESSION"
        value = var.enable_compression ? "true" : "false"
      }

      # Backend API configuration (if provided)
      dynamic "env" {
        for_each = var.backend_api_url != null ? [1] : []
        content {
          name  = "BACKEND_API_URL"
          value = var.backend_api_url
        }
      }

      dynamic "env" {
        for_each = var.backend_api_url != null ? [1] : []
        content {
          name  = "API_PATH_PREFIX"
          value = var.api_path_prefix
        }
      }

      # Additional environment variables
      dynamic "env" {
        for_each = var.proxy_environment_variables
        content {
          name  = env.key
          value = env.value
        }
      }

      resources {
        limits = {
          cpu    = var.proxy_resources.cpu
          memory = var.proxy_resources.memory
        }
      }

      ports {
        container_port = 8080
      }
    }

    scaling {
      min_instance_count = 0
      max_instance_count = 10
    }
  }

  # Configure ingress to only allow load balancer traffic
  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  labels = local.labels

  depends_on = [
    google_project_service.services,
    google_storage_bucket_iam_member.proxy_storage_access
  ]
}

# Network endpoint group for Cloud Run
resource "google_compute_region_network_endpoint_group" "proxy_neg" {
  name                  = "${var.namespace}-proxy-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = google_cloud_run_v2_service.gcs_proxy.name
  }

  depends_on = [google_project_service.services]
}

# Backend service for the proxy
resource "google_compute_backend_service" "proxy_backend" {
  name                            = local.backend_service_name
  protocol                        = "HTTP"
  timeout_sec                     = 30
  connection_draining_timeout_sec = 300

  backend {
    group = google_compute_region_network_endpoint_group.proxy_neg.id
  }

  # Enable IAP on the backend service
  iap {
    enabled              = true
    oauth2_client_id     = google_iap_client.iap_client.client_id
    oauth2_client_secret = google_iap_client.iap_client.secret
  }

  depends_on = [google_project_service.services]
}

# Reserve an external IP
resource "google_compute_global_address" "static_ip" {
  name   = "${var.namespace}-proxy-ip"
  labels = local.labels

  depends_on = [google_project_service.services]
}

# Create HTTPS certificate
resource "google_compute_managed_ssl_certificate" "ssl_cert" {
  name = "${var.namespace}-proxy-cert"

  managed {
    domains = var.domains
  }

  depends_on = [google_project_service.services]
}

# URL map for the load balancer
resource "google_compute_url_map" "url_map" {
  name            = "${var.namespace}-proxy-lb"
  default_service = google_compute_backend_service.proxy_backend.self_link
}

# HTTPS target proxy
resource "google_compute_target_https_proxy" "target_proxy" {
  name             = "${var.namespace}-proxy-target"
  url_map          = google_compute_url_map.url_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_cert.self_link]

  lifecycle {
    ignore_changes = [ssl_policy]
  }
}

# Global forwarding rule
resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name                  = "${var.namespace}-proxy-fwd-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.static_ip.address
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.target_proxy.self_link
  labels                = local.labels
}

# IAP brand (OAuth consent screen)
resource "google_iap_brand" "project_brand" {
  count = var.create_iap_brand ? 1 : 0

  support_email     = var.support_email
  application_title = var.application_title
  project           = data.google_client_config.current.project

  depends_on = [google_project_service.services]
}

# IAP OAuth client
resource "google_iap_client" "iap_client" {
  display_name = "${var.namespace} IAP Client"
  brand        = var.create_iap_brand ? google_iap_brand.project_brand[0].name : var.existing_iap_brand
}

# Allow time for backend service with IAP to be fully propagated
resource "time_sleep" "wait_for_backend_service" {
  depends_on = [
    google_compute_backend_service.proxy_backend,
    google_iap_client.iap_client
  ]

  create_duration = "30s"
}

# IAM policy for IAP access
resource "google_iap_web_backend_service_iam_binding" "iap_access" {
  count = length(var.iap_users) > 0 ? 1 : 0

  project             = data.google_client_config.current.project
  web_backend_service = local.backend_service_name
  role                = "roles/iap.httpsResourceAccessor"
  members             = var.iap_users

  depends_on = [
    google_compute_backend_service.proxy_backend,
    google_iap_client.iap_client,
    google_project_service.services,
    time_sleep.wait_for_backend_service
  ]
}

# Allow Cloud Run to be invoked by load balancer (IAP will handle authentication)
resource "google_cloud_run_v2_service_iam_member" "proxy_invoker" {
  project  = data.google_client_config.current.project
  location = google_cloud_run_v2_service.gcs_proxy.location
  name     = google_cloud_run_v2_service.gcs_proxy.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
