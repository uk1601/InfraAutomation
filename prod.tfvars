project_id = "prod-gcp-project-id"
region     = "us-central1"
vpc_name   = "prod-vpc"
subnets    = [
  {
    subnet_name  = "prod-webapp"
    subnet_range = "10.0.3.0/24"
  },
  {
    subnet_name  = "prod-db"
    subnet_range = "10.0.4.0/24"
  }
]
gcp_project_id = "white-rune-413805"
gcp_region = "us-central1"
gcp_credentials_file = "white-rune-413805-99184637009c.json"