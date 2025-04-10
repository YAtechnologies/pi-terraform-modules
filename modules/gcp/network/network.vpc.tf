resource "google_compute_network" "vpc_network" {
  name                            = "vpc-network-${local.environment}"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
  mtu                             = 1460
  depends_on                      = [google_project_service.services]
}

resource "google_vpc_access_connector" "cloud_run_access_connector" {
  count         = var.vpc_access_connector_enabled ? 1 : 0
  name          = "vpc-conn-${local.environment}"
  min_instances = 2
  max_instances = var.vpcac_max_instances
  subnet {
    name = google_compute_subnetwork.vpc_connector_subnet.name
  }
  depends_on = [
    google_compute_subnetwork.vpc_connector_subnet
  ]
}

# /******************************************
# 	Shared VPC
#  *****************************************/
# resource "google_compute_shared_vpc_host_project" "shared_vpc_host" {
#   provider = google-beta

#   count      = var.shared_vpc_host ? 1 : 0
#   project    = data.google_client_config.current.project
#   depends_on = [google_compute_network.vpc]
# }
