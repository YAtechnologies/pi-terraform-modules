locals {
  project = data.google_client_config.current.project

  project_number = data.google_project.project.number

  existing_iap_brand = var.existing_iap_brand != null ? var.existing_iap_brand : "projects/${local.project_number}/brands/${local.project_number}"

  labels = merge({
    namespace = var.namespace,
    terraform = "true"
    tf_module = "gcs-iap-proxy"
    project   = local.project
  }, var.labels)

  services = var.enable_services ? [
    "compute.googleapis.com",
    "run.googleapis.com",
    "iap.googleapis.com",
    "storage.googleapis.com",
  ] : []

  # IAP audience format - use predictable name to avoid circular dependency
  backend_service_name = "${var.namespace}-proxy-backend"
  iap_audience         = "/projects/${data.google_client_config.current.id}/global/backendServices/${local.backend_service_name}"
}
