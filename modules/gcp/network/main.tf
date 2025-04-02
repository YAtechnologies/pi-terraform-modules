
# Enable the services needed for this module
resource "google_project_service" "services" {
  for_each           = toset(local.services)
  project            = data.google_client_config.current.project
  service            = each.value
  disable_on_destroy = false
}
