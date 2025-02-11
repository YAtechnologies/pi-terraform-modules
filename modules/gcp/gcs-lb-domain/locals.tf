locals {
  project = data.google_client_config.current.project

  labels = merge({
    namespace = var.namespace,
    domains   = join(", ", var.domains),
    terraform = "true"
    tf_module = "gcp/gcs-lb-domain"
    project   = local.project
  }, var.labels)

  services = var.enable_services ? [
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
  ] : []
}
