locals {
  project     = data.google_client_config.current.project
  environment = var.environment

  labels = merge({
    namespace   = var.namespace,
    terraform   = "true"
    tf_module   = "cloud-run-placeholder"
    project     = local.project
    environment = local.environment
  }, var.labels)

  services = var.enable_services ? [
    "run.googleapis.com",
    "secretmanager.googleapis.com",
  ] : []
}
