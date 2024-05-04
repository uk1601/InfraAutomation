resource "google_service_account" "ops_agent_account" {
  account_id   = "ops-agent-account"
  display_name = "Ops Agent Service Account"
}

resource "google_project_iam_binding" "logging_admin" {
  role = "roles/logging.admin"
  members = [
    "serviceAccount:${google_service_account.ops_agent_account.email}",
  ]
  project = var.project_id
}

resource "google_project_iam_binding" "pubsub" {
  role = "roles/pubsub.publisher"
  members =[
    "serviceAccount:${google_service_account.ops_agent_account.email}"
  ]
  project = var.project_id
}

resource "google_project_iam_binding" "monitoring_metric_writer" {
  role = "roles/monitoring.metricWriter"
  members = [
    "serviceAccount:${google_service_account.ops_agent_account.email}",
  ]
  project = var.project_id
} 