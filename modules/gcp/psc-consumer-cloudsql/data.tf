data "google_sql_database_instance" "db_instance" {
  name    = var.cloud_sql.name
  project = var.cloud_sql.project
}

data "google_compute_subnetwork" "subnetwork" {
  name    = var.consumer.subnetwork
  project = var.consumer.project
  region  = var.consumer.region
}
