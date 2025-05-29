variable "namespace" {
  description = "The namespace to prefix the GCP resources IDs with"
  type        = string
}

variable "bucket_name" {
  description = "The name of the GCS bucket to serve files from"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy the Cloud Run service"
  type        = string
  default     = "europe-west1"
}

variable "domains" {
  description = "The domain names to serve the application on"
  type        = list(string)
}

variable "proxy_image" {
  description = "The container image for the GCS proxy service"
  type        = string
  default     = "gcr.io/cloudrun/hello" # Default placeholder, should be replaced with actual proxy image
}

variable "iap_users" {
  description = "List of users/groups that should have access via IAP"
  type        = list(string)
  default     = []
}

variable "support_email" {
  description = "Support email for IAP OAuth consent screen"
  type        = string
}

variable "application_title" {
  description = "Application title for IAP OAuth consent screen"
  type        = string
  default     = "GCS IAP Proxy"
}

variable "proxy_resources" {
  description = "Resource limits for the Cloud Run proxy service"
  type = object({
    cpu    = optional(string, "1000m")
    memory = optional(string, "512Mi")
  })
  default = {}
}

variable "proxy_environment_variables" {
  description = "Additional environment variables for the proxy service"
  type        = map(string)
  default     = {}
}

variable "backend_api_url" {
  description = "Backend API URL for reverse proxy functionality (optional)"
  type        = string
  default     = null
}

variable "api_path_prefix" {
  description = "Path prefix for API requests that should be proxied to the backend"
  type        = string
  default     = "/api"
}

variable "labels" {
  description = "Resource labels"
  type        = map(string)
  default     = {}
}

variable "enable_services" {
  description = "Whether to enable the services needed for this module"
  type        = bool
  default     = true
}

variable "create_iap_brand" {
  description = "Whether to create a new IAP brand (OAuth consent screen). Set to false if one already exists"
  type        = bool
  default     = true
}

variable "existing_iap_brand" {
  description = "Full name of existing IAP brand to use (if create_iap_brand is false). Format: projects/PROJECT_NUMBER/brands/BRAND_ID"
  type        = string
  default     = null
}

variable "spa_mode" {
  description = "Enable SPA (Single Page Application) mode - serves index.html for routes that don't match files"
  type        = bool
  default     = true
}

variable "spa_fallback_file" {
  description = "File to serve when SPA mode is enabled and no file is found (default: index.html)"
  type        = string
  default     = "index.html"
}

variable "enable_compression" {
  description = "Enable gzip compression for static files served from GCS (does not affect API proxy responses)"
  type        = bool
  default     = true
}
