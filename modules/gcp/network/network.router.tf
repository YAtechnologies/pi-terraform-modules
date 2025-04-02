resource "google_compute_router" "untrusted_subnet_router" {
  name    = "${local.environment}-untrusted-subnet-router"
  region  = google_compute_subnetwork.untrusted_subnet.region
  network = google_compute_network.vpc_network.id
  bgp {
    asn = 64514
  }
  depends_on = [
    google_compute_network.vpc_network
  ]
}

resource "google_compute_router_nat" "untrusted_subnet_router_nat" {
  name                               = "${local.environment}-untrusted-subnet-nat"
  router                             = google_compute_router.untrusted_subnet_router.name
  region                             = google_compute_router.untrusted_subnet_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  drain_nat_ips                      = []
  max_ports_per_vm                   = 0
  min_ports_per_vm                   = 0
  nat_ips                            = []
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  depends_on = [
    google_compute_router.untrusted_subnet_router
  ]
}
