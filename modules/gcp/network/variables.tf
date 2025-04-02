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

# i.e. 10.42
variable "cidr_prefix" {
  type        = string
  default     = null
  description = "the first 2 numbers of the ipv4 range we want to use for this project. i.e. 10.42"
}


# Flow logs
variable "subnet_flow_logs" {
  type        = bool
  description = "Toggle value for flow logs"
  default     = false
}
variable "subnet_flow_logs_interval" {
  type        = string
  description = "Default value is INTERVAL_5_SEC. Possible values are: INTERVAL_5_SEC, INTERVAL_30_SEC, INTERVAL_1_MIN, INTERVAL_5_MIN, INTERVAL_10_MIN, INTERVAL_15_MIN."
  default     = "INTERVAL_5_SEC"
}
variable "subnet_flow_logs_sampling" {
  type        = string
  description = "The value of the field must be in [0, 1]. Set the sampling rate of VPC flow logs within the subnetwork where 1.0 means all collected logs are reported and 0.0 means no logs are reported. Default is 0.5 which means half of all collected logs are reported."
  default     = "0.5"
}
variable "subnet_flow_logs_metadata" {
  type        = string
  description = "Configures whether metadata fields should be added to the reported VPC flow logs. Default value is INCLUDE_ALL_METADATA. Possible values are: EXCLUDE_ALL_METADATA, INCLUDE_ALL_METADATA, CUSTOM_METADATA."
  default     = null
}
variable "subnet_flow_logs_filter" {
  type        = string
  description = "Export filter used to define which VPC flow logs should be logged, as as CEL expression. See https://cloud.google.com/vpc/docs/flow-logs#filtering for details on how to format this field. The default value is 'true', which evaluates to include everything."
  default     = "true"
}
variable "subnet_flow_logs_metadata_fields" {
  type        = list(string)
  description = "List of metadata fields that should be added to reported logs. Can only be specified if VPC flow logs for this subnetwork is enabled and `metadata` is set to CUSTOM_METADATA."
  default     = []
}
