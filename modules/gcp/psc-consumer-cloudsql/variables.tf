variable "namespace" {
  description = "The namespace to prefix the GCP resources IDs with"
  type        = string
}

variable "labels" {
  description = "Resource labels."
  type        = map(string)
  default     = {}
}

variable "environment" {
  default     = "" # dev stg, prd
  type        = string
  description = "target environment"
  validation {
    condition     = contains(["dev", "stg", "qa", "prd"], var.environment)
    error_message = "Allowed values for input_parameter are \"dev\", \"stg\", \"qa\", or \"prd\"."
  }
}

variable "cloud_sql" {
  type = object({
    project = string
    name    = string

  })
  description = "The target CloudSQL project and instance name"
  default     = null
}

variable "consumer" {
  type = object({
    project          = string
    subnetwork       = string
    region           = string
    ip_address       = string
    service_accounts = list(string)
    connection_limit = optional(number, 10)
  })
  description = "The consumer project, service account and network details"
  default     = null
}
