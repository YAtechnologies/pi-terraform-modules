output "service_account" {
  value       = var.service_account_email
  description = "The service account to use for CI/CD"
}

output "wip_provider" {
  value       = google_iam_workload_identity_pool_provider.wip_provider.workload_identity_pool_provider_id
  description = "The Workload Identity Provider to use for Github Actions"
}

output "connection_info" {
  value = {
    project      = local.project
    service_account = var.service_account_email
    wip_provider = google_iam_workload_identity_pool_provider.wip_provider.workload_identity_pool_provider_id
    repositories = var.repositories
  }
}
