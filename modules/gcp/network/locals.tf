locals {
  project     = data.google_client_config.current.project
  environment = var.environment

  labels = merge({
    namespace   = var.namespace,
    terraform   = "true"
    tf_module   = "network"
    project     = local.project
    environment = local.environment
  }, var.labels)

  services = var.enable_services ? [
    "vpcaccess.googleapis.com",
    "servicenetworking.googleapis.com",
  ] : []


  # IP subnet calculations
  # tflint-ignore: terraform_unused_declarations
  base_cidr_block = "${var.cidr_prefix}.0.0/16"
  # tflint-ignore: terraform_unused_declarations
  cidr_block = "${var.cidr_prefix}.32.0/16"

  public_sub_cidr        = "${var.cidr_prefix}.32.0/22"
  isolated_sub_cidr      = "${var.cidr_prefix}.48.0/22"
  vpc_connector_sub_cidr = "${var.cidr_prefix}.64.0/28"
  untrusted_sub_cidr     = "${var.cidr_prefix}.128.0/18"
}
