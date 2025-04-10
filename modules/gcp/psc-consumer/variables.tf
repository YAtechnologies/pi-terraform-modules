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

variable "ip_address_type" {
  type        = string
  default     = "INTERNAL"
  description = "compute address type for the PSC endpoint"
}

variable "vpc_network_id" {
  default     = null
  type        = string
  description = "consumer vpc network id"
}

variable "vpc_subnetwork_id" {
  default     = null
  type        = string
  description = "consumer subnetwork id (must be same region as producer)"
}

variable "psc_producer_region" {
  default     = null
  type        = string
  description = "gcp region for the producer service exposed via PSC"
}

variable "psc_producer_service_name" {
  default     = null
  type        = string
  description = "producer service name we want to connect to with PSC"
}

variable "psc_producer_project" {
  default     = null
  type        = string
  description = "gcp project hosting the producer service"
}
