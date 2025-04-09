locals {
  project     = data.google_client_config.current.project
  environment = var.environment

  labels = merge({
    namespace   = var.namespace,
    terraform   = "true"
    tf_module   = "psc-consumer"
    project     = local.project
    environment = local.environment
  }, var.labels)

  # services = var.enable_services ? [
  #   "vpcaccess.googleapis.com",
  #   "servicenetworking.googleapis.com",
  # ] : []

  producer_service_target = "projects/${var.psc_producer_project}/regions/${var.psc_producer_region}/serviceAttachments/${var.psc_producer_service_name}"
  uniq_reference          = substr(md5(local.producer_service_target), 0, 5)
  trim_service_name       = substr(var.psc_producer_service_name, 0, 10)
  computed_name           = "${local.uniq_reference}-${local.trim_service_name}-${local.environment}"
}
