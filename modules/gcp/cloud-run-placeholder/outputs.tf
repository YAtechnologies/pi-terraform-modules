# Export the labels used by this module
output "labels" {
  description = "The labels used by this module"
  value = {
    for key, value in local.labels : key => value
  }
}

output "cloud_run_service" {
  description = "cloud run service"
  value       = google_cloud_run_v2_service.cr_item
}

output "cloud_run_service_iam" {
  description = "expose cloud run permissions"
  value       = google_cloud_run_v2_service_iam_member.cr_item_permission
}
