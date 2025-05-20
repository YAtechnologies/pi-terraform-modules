resource "google_project_iam_member" "service_account_iam" {
  # for each service account in the consumer project, give it the role of cloudsql.instanceUser
  for_each = toset(var.consumer.service_accounts)
  project  = var.cloud_sql.project
  role     = "roles/cloudsql.instanceUser"
  member   = "serviceAccount:${each.value}"

  // give a service account role of sql.client only to a specific database
  condition {
    title       = "Allow SQL Client Role"
    description = "Allows SQL Client role for ${data.google_sql_database_instance.db_instance.name}"
    expression  = "resource.name == '${data.google_sql_database_instance.db_instance.self_link}'"
  }
}

resource "google_network_connectivity_service_connection_policy" "psc_policy" {
  project       = var.consumer.project
  name          = "${var.namespace}-psc-policy"
  location      = var.consumer.region
  service_class = "google-cloud-sql"
  description   = "PSC policy for ${data.google_sql_database_instance.db_instance.name}"
  network       = data.google_compute_subnetwork.subnetwork.network

  psc_config {
    subnetworks = [data.google_compute_subnetwork.subnetwork.id]
    limit       = var.consumer.connection_limit
  }
}

resource "google_compute_address" "psc_ip_endpoint" {
  name         = "${var.namespace}-psc-ip-endpoint"
  project      = var.consumer.project
  description  = "PSC IP endpoint for ${data.google_sql_database_instance.db_instance.name}"
  subnetwork   = var.consumer.subnetwork
  address_type = "INTERNAL"
  address      = var.consumer.ip_address
  region       = var.consumer.region
}

resource "google_compute_forwarding_rule" "psc_fwd_rule" {
  name                    = "${var.namespace}-psc-fwd-rule"
  project                 = var.consumer.project
  region                  = var.consumer.region
  load_balancing_scheme   = "" # Leave this blank
  target                  = data.google_sql_database_instance.db_instance.psc_service_attachment_link
  network                 = data.google_compute_subnetwork.subnetwork.network
  ip_address              = google_compute_address.psc_ip_endpoint.id
  allow_psc_global_access = true
}
