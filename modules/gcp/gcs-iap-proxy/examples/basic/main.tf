# Example usage of the GCS IAP Proxy module with reverse proxy functionality

module "gcs_iap_proxy" {
  source = "../../"

  namespace         = "example"
  bucket_name       = "my-static-files-bucket"
  region            = "us-central1"
  domains           = ["dashboard.example.com"]
  support_email     = "support@example.com"
  application_title = "Example Dashboard"

  # Replace with your actual container image
  proxy_image = "gcr.io/my-project/gcs-proxy:latest"

  # IAP users
  iap_users = [
    "user:admin@example.com",
    "user:user1@example.com",
    "group:developers@example.com"
  ]

  # Reverse proxy configuration for backend APIs
  backend_api_url = "https://api-backend.example.com"
  api_path_prefix = "/api"

  # SPA (Single Page Application) configuration
  spa_mode          = true         # Enable SPA fallback (default: true)
  spa_fallback_file = "index.html" # File to serve for SPA routes (default: index.html)

  # Optional configuration
  enable_cdn      = true
  enable_services = true

  proxy_resources = {
    cpu    = "1000m"
    memory = "512Mi"
  }

  proxy_environment_variables = {
    LOG_LEVEL = "INFO"
    # Add any other environment variables your backend might need
  }

  labels = {
    environment = "development"
    team        = "platform"
    app         = "dashboard"
  }
}

# Output the URLs
output "dashboard_urls" {
  description = "URLs for accessing the dashboard"
  value       = module.gcs_iap_proxy.urls
}

output "api_urls" {
  description = "URLs for accessing the APIs"
  value       = module.gcs_iap_proxy.api_urls
}

output "static_ip" {
  description = "Static IP address"
  value       = module.gcs_iap_proxy.ip.address
}

output "iap_audience" {
  description = "IAP audience for backend validation"
  value       = module.gcs_iap_proxy.iap_audience
}

output "proxy_config" {
  description = "Reverse proxy configuration"
  value       = module.gcs_iap_proxy.reverse_proxy_config
}
