resource "google_compute_global_address" "webapp_static_ip" {
  name = "webapp-static-ip"
}

resource "google_compute_firewall" "lb_to_instances" {
  name    = "allow-lb-to-instances"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["3000", "8443","22"] # Assuming your app serves HTTP on 8080 and HTTPS on 8443
  }
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22",google_compute_global_forwarding_rule.https_forwarding_rule.ip_address]
  target_tags   = ["allow-lb"] 
  depends_on = [ google_compute_network.vpc ]
}


resource "google_compute_backend_service" "app_backend_service" {
  name             = "app-backend-service"
  health_checks    = [google_compute_health_check.app_health_check.id]
  protocol = "HTTP"
  backend {
    group = google_compute_instance_group_manager.app_manager.instance_group
  }
  timeout_sec = 120
  log_config {
    enable = true
    sample_rate = 1.0
  }
}

resource "google_compute_managed_ssl_certificate" "app_ssl_cert" {
  name    = "app-ssl-cert"
  project = var.project_id
  managed {
    domains = [var.dns_record_name]
  }
}
resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  name       = "app-https-forwarding-rule"
  target     = google_compute_target_https_proxy.app_https_proxy.self_link
  port_range = "443"
}

resource "google_compute_target_https_proxy" "app_https_proxy" {
  name             = "app-https-proxy"
  url_map          = google_compute_url_map.app_url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.app_ssl_cert.id]
}

resource "google_compute_url_map" "app_url_map" {
  name            = "app-url-map"
  default_service = google_compute_backend_service.app_backend_service.id
}
