resource "google_compute_address" "psc_consumer_address" {
  name = "psc-addr-${local.computed_name}"

  region       = var.psc_producer_region
  subnetwork   = var.vpc_subnetwork_id
  address_type = "INTERNAL"
}

# in case you don't have subnet in same region as the producer region you can create subnet
#
resource "google_compute_forwarding_rule" "psc_consumer_fwdrule" {
  name   = "psc-fwr-${local.computed_name}"
  target = local.producer_service_target
  # the target is the ID of the attachement service created in project A

  region                  = var.psc_producer_region
  load_balancing_scheme   = "" # let it like that
  network                 = var.vpc_network_id
  subnetwork              = var.vpc_subnetwork_id
  ip_address              = google_compute_address.psc_consumer_address.id
  allow_psc_global_access = true
}
