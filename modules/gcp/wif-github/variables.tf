variable "namespace" {
  type        = string
  description = "The namespace to use as a prefix for the resources created by this module"
}

variable "repositories" {
  type        = list(string)
  description = "A list of repositories in the form of 'owner/repo'"

  validation {
    condition     = length(var.repositories) > 0
    error_message = "The repositories variable must contain at least one repository"
  }

  validation {
    condition     = alltrue(flatten([for repo in var.repositories : can(regex("^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+$", repo))]))
    error_message = "Each repository must be in the format 'owner/repo'"
  }
}

variable "github_organization" {
  default     = "YAtechnologies"
  type        = string
  description = "A Github Organization name to use as a constraint for the workload identity federation"
}

variable "service_account_email" {
  type        = string
  description = "The service account email to use for the workload identity federation"
}
