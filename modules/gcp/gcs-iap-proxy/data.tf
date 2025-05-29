# Get current project configuration
data "google_client_config" "current" {}

# Get project details including project number
data "google_project" "current" {
  project_id = data.google_client_config.current.project
}
