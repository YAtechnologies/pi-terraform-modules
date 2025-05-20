output "psc_ip_endpoint" {
  value = {
    ip                    = google_compute_address.psc_ip_endpoint.address
    psc_connection_status = google_compute_forwarding_rule.psc_fwd_rule.psc_connection_status
  }
}
