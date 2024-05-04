# provider "google" {
#   project     = var.gcp_project_id
#   region      = var.gcp_region

#   credentials = var.gcp_credentials_file != "" ? var.gcp_credentials_file : null
# }

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.24.0"
    }
  }
}

provider "google" {
  region  = var.gcp_region
  project = var.gcp_project_id
  credentials = var.gcp_credentials_file != "" ? var.gcp_credentials_file : null
}
