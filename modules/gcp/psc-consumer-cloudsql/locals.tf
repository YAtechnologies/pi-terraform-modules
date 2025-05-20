locals {
  labels = merge({
    namespace   = var.namespace,
    terraform   = "true"
    tf_module   = "psc-consumer-cloudsql"
    project     = var.consumer.project
    environment = var.environment
  }, var.labels)
}
