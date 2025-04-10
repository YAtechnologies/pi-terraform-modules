# Enable the services needed for this module
resource "google_project_service" "services" {
  for_each           = toset(local.services)
  project            = data.google_client_config.current.project
  service            = each.value
  disable_on_destroy = false
}

# TODO: Leave only required config, we DON'T want to manage state in terraform for this
resource "google_cloud_run_v2_service" "cr_item" {
  name     = var.cr_item_name
  location = var.gcp_provider_region
  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }
  lifecycle {
    ignore_changes        = all
    create_before_destroy = true
  }
}

# Make the deployment accessible by the public
resource "google_cloud_run_v2_service_iam_member" "cr_item_permission" {
  name       = var.cr_item_name
  location   = var.gcp_provider_region
  role       = "roles/run.invoker"
  member     = "allUsers"
  depends_on = [google_cloud_run_v2_service.cr_item]
}
