resource "google_compute_instance_template" "app_template" {
  name_prefix  = "app-instance-"
  machine_type = "e2-standard-2"
  region       = var.region
  tags         = ["webapp", "allow-lb"]
  disk {
    source_image = data.google_compute_image.latest_custom_image.self_link
    auto_delete  = true
    boot         = true
    # disk_encryption_key {
    #   kms_key_self_link = var.encryption_key_name_vm
    # }
  }
  network_interface {
    network    = var.vpc_name
    subnetwork = "dev-webapp"
    access_config {}
  }
  service_account {
    email = google_service_account.ops_agent_account.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform",
      "userinfo-email",
      "compute-ro",
      "storage-ro",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/pubsub"]
  }
  metadata_startup_script = file("${path.module}/startup.sh")
  lifecycle {
    create_before_destroy = true
  }
  metadata = {
    db_user     = google_sql_user.webapp_user.name
    db_password = random_password.password.result
    db_host     = google_sql_database_instance.instance.private_ip_address
  }

}


resource "google_compute_health_check" "app_health_check" {
  name                = "app-health-check"
  check_interval_sec  = 25
  timeout_sec         = 20
  unhealthy_threshold = 2
  healthy_threshold   = 2

  http_health_check {
    request_path = "/healthz"
    port         = 3000
  }
  log_config {
    enable = true
  }
}


resource "google_compute_autoscaler" "app_autoscaler" {
  name    = "app-autoscaler-1"
  target  = google_compute_instance_group_manager.app_manager.id
  project = var.project_id
  zone    = var.zone

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 120
    cpu_utilization {
      target = 0.05
    }
  }
}

resource "google_compute_instance_group_manager" "app_manager" {
  name               = "instance-group-max"
  base_instance_name = "app-instance"
  target_size        = 1
  zone               = var.zone
  version {
    name              = "v1"
    instance_template = google_compute_instance_template.app_template.self_link
  }
  auto_healing_policies {
    health_check      = google_compute_health_check.app_health_check.self_link
    initial_delay_sec = 60
  }
  named_port {
    name = "http"
    port = 3000
  }
}
