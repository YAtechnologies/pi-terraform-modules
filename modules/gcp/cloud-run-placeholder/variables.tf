variable "namespace" {
  description = "The namespace to prefix the GCP resources IDs with"
  type        = string
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

variable "gcp_provider_region" {
  default     = ""
  type        = string
  description = "GCP default region"
}

variable "environment" {
  default     = "" # dev stg, prd
  type        = string
  description = "target environment"
  validation {
    condition     = contains(["dev", "stg", "qa", "prd"], var.environment)
    error_message = "Allowed values for input_parameter are \"a\", \"b\", or \"c\"."
  }
}

variable "cr_item_name" {
  type        = string
  default     = null
  description = "cloud run service name"
}
