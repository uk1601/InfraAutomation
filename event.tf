resource "google_pubsub_topic" "verify_email" {
  name    = "verify_email"
  project = var.project_id
}

resource "google_cloudfunctions2_function" "verify_email_function-main" {
  name        = "verify-email-function-main"
  location    = var.region
  description = "User mail verification"
  build_config {
    runtime     = "nodejs20"
    entry_point = "helloPubSub"
    source {
      storage_source {
        bucket = "my-cloud-functions-bucket-csye"
        object = "function.zip"
      }
    }
  }
  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = "60"
    vpc_connector      = google_vpc_access_connector.sql_connector.name
    ingress_settings   = "ALLOW_ALL"

    environment_variables = {
      db_user                    = google_sql_user.webapp_user.name
      db_password                = random_password.password.result
      db_host                    = google_sql_database_instance.instance.private_ip_address
      mailgun_from_mail_id       = var.mailgun_from_mail_id
      verification_link_base_url = var.verification_link_base_url
      mailgun_url                = var.mailgun_url
      api_key                    = var.api_key

      TOKEN_EXPIRATION_TIME = "120000"
    }
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.verify_email.id
    retry_policy   = "RETRY_POLICY_UNSPECIFIED"
  }
  depends_on = [google_pubsub_topic.verify_email]
}

resource "google_vpc_access_connector" "sql_connector" {
  name          = "sql-connector"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.8.0.0/28"
}
