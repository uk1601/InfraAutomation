resource "google_compute_network" "vpc" {
  project                         = var.project_id
  name                            = var.vpc_name
  auto_create_subnetworks         = false
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "subnets" {
  for_each      = { for subnet in var.subnets : subnet.subnet_name => subnet }
  name          = each.value.subnet_name
  ip_cidr_range = each.value.subnet_range
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_route" "default_internet_gateway" {
  name             = "default-route-${var.vpc_name}"
  dest_range       = var.dest_range
  network          = google_compute_network.vpc.id
  next_hop_gateway = "default-internet-gateway"
  depends_on       = [google_compute_network.vpc]
  project          = var.gcp_project_id
}

resource "google_compute_firewall" "app_traffic_firewall" {
  name    = "allow-app-traffic"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = [var.app_port, "22"]
  }
  source_tags   = ["webapp"]
  source_ranges = [google_compute_global_forwarding_rule.https_forwarding_rule.ip_address, "35.191.0.0/16", "130.211.0.0/22", "35.235.240.0/20"]
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
  depends_on = [google_compute_network.vpc]
}

data "google_compute_image" "latest_custom_image" {
  family  = var.image_family
  project = var.custom_project_id
}

resource "google_project_service" "service_networking" {
  service    = "servicenetworking.googleapis.com"
  depends_on = [google_compute_network.vpc]
}

resource "google_compute_global_address" "private_ip_alloc" {
  name          = var.private_ip_alloc_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.private_ip_prefix_length
  network       = google_compute_network.vpc.id
  depends_on    = [google_compute_network.vpc]
}


resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
  depends_on = [ google_project_service.service_networking, google_compute_global_address.private_ip_alloc, google_compute_network.vpc ]
}
