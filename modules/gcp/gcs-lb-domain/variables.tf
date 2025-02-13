variable "namespace" {
  description = "The namespace to prefix the GCP resources IDs with"
  type        = string
}

variable "bucket_name" {
  description = "The name of the bucket to serve"
  type        = string
}

variable "enable_cdn" { 
  description = "Whether to enable CDN for the bucket backend"
  type        = bool
  default     = false
}

variable "domains" {
  description = "The domain name to serve the bucket on"
  type        = list(string)
}

variable "labels" {
  description = "Resource labels."
  type        = map(string)
  default     = {}
}

variable "enable_services" {
  description = "Whether to enable the services needed for this module"
  type        = bool
  default     = false
}
