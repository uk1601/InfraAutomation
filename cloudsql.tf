
resource "google_sql_database_instance" "instance" {
  name                = "db-instance-${random_string.instance_suffix.result}"
  region              = var.region
  database_version    = "MYSQL_5_7"
  depends_on          = [google_service_networking_connection.private_vpc_connection]
  # encryption_key_name = var.encryption_key_name
  lifecycle {
    prevent_destroy = false
  }
  settings {
    tier = "db-f1-micro"
    backup_configuration {
      enabled            = true
      binary_log_enabled = true
    }

    ip_configuration {
      ipv4_enabled    = var.ipv4_enabled
      private_network = "projects/${var.project_id}/global/networks/${var.vpc_name}"
    }

    disk_type = var.disk_type
    disk_size = var.disk_size

    location_preference {
      zone = var.zone
    }

    database_flags {
      name  = "sql_mode"
      value = "TRADITIONAL"
    }
    database_flags {
      name  = "log_bin_trust_function_creators"
      value = "on"
    }
    availability_type = var.availability_type
  }
}
resource "google_sql_database" "webapp_db" {
  name     = "webapp"
  instance = google_sql_database_instance.instance.name
}

resource "random_password" "password" {
  length           = 16
  special          = false
  override_special = "_%@"
}
resource "google_sql_user" "webapp_user" {
  name     = "webapp"
  instance = google_sql_database_instance.instance.name
  password = random_password.password.result
}
