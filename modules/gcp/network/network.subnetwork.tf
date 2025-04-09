# Subnets new layout
# Subnet for internet-facing resources
# Hosts publicly accessible components, further isolated from sensitive systems.
resource "google_compute_subnetwork" "public_subnet" {
  name          = "public-subnet"
  ip_cidr_range = local.public_sub_cidr
  # Public subnet accessible from the internet
  private_ipv6_google_access = false
  private_ip_google_access   = false
  network                    = google_compute_network.vpc_network.self_link
  region                     = var.gcp_provider_region
  depends_on                 = [google_compute_network.vpc_network]
  dynamic "log_config" {
    for_each = coalesce(var.subnet_flow_logs, false) ? [1] : []
    content {
      aggregation_interval = var.subnet_flow_logs_interval
      flow_sampling        = var.subnet_flow_logs_sampling
      metadata             = var.subnet_flow_logs_metadata
      filter_expr          = var.subnet_flow_logs_filter
      metadata_fields      = var.subnet_flow_logs_metadata == "CUSTOM_METADATA" ? var.subnet_flow_logs_metadata_fields : null
    }
  }
}
# Hosts untrusted components like web servers, firewalled from PII or financial data.
resource "google_compute_subnetwork" "untrusted_subnet" {
  name          = "untrusted-subnet"
  ip_cidr_range = local.untrusted_sub_cidr
  # Private subnet with no direct access from the internet
  private_ip_google_access = false
  network                  = google_compute_network.vpc_network.self_link
  region                   = var.gcp_provider_region
  depends_on               = [google_compute_network.vpc_network]
  dynamic "log_config" {
    for_each = coalesce(var.subnet_flow_logs, false) ? [1] : []
    content {
      aggregation_interval = var.subnet_flow_logs_interval
      flow_sampling        = var.subnet_flow_logs_sampling
      metadata             = var.subnet_flow_logs_metadata
      filter_expr          = var.subnet_flow_logs_filter
      metadata_fields      = var.subnet_flow_logs_metadata == "CUSTOM_METADATA" ? var.subnet_flow_logs_metadata_fields : null
    }
  }
}

# Stores systems processing financial data, with no internet access.
resource "google_compute_subnetwork" "isolated_subnet" {
  name          = "isolated-subnet"
  ip_cidr_range = local.isolated_sub_cidr
  # Restricted subnet for PCI DSS compliant components
  private_ip_google_access = true
  network                  = google_compute_network.vpc_network.self_link
  region                   = var.gcp_provider_region
  depends_on               = [google_compute_network.vpc_network]
  dynamic "log_config" {
    for_each = coalesce(var.subnet_flow_logs, false) ? [1] : []
    content {
      aggregation_interval = var.subnet_flow_logs_interval
      flow_sampling        = var.subnet_flow_logs_sampling
      metadata             = var.subnet_flow_logs_metadata
      filter_expr          = var.subnet_flow_logs_filter
      metadata_fields      = var.subnet_flow_logs_metadata == "CUSTOM_METADATA" ? var.subnet_flow_logs_metadata_fields : null
    }
  }
}

resource "google_compute_subnetwork" "vpc_connector_subnet" {
  name                       = "vpc-connector-subnet"
  ip_cidr_range              = local.vpc_connector_sub_cidr
  region                     = var.gcp_provider_region
  private_ip_google_access   = false
  private_ipv6_google_access = false
  network                    = google_compute_network.vpc_network.id
  depends_on                 = [google_compute_network.vpc_network]

  dynamic "log_config" {
    for_each = coalesce(var.subnet_flow_logs, false) ? [1] : []
    content {
      aggregation_interval = var.subnet_flow_logs_interval
      flow_sampling        = var.subnet_flow_logs_sampling
      metadata             = var.subnet_flow_logs_metadata
      filter_expr          = var.subnet_flow_logs_filter
      metadata_fields      = var.subnet_flow_logs_metadata == "CUSTOM_METADATA" ? var.subnet_flow_logs_metadata_fields : null
    }
  }
}
