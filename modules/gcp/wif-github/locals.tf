locals {
  project = data.google_client_config.current.project
  service_account_id = "projects/${project}/serviceAccounts/${var.service_account_email}"
}
