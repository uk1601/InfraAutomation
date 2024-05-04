variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}
variable "custom_project_id" {
  description = "The ID of the GCP project"
  type        = string
}
variable "region" {
  description = "The region to host the VPC"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "subnets" {
  description = "A list of subnets to be created"
  type = list(object({
    subnet_name = string
    subnet_range = string
  }))
}

variable "gcp_project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "The GCP region"
  type        = string
}

variable "gcp_credentials_file" {
  description = "Path to the GCP credentials file"
  type        = string
  default     = ""
}

variable "zone" {
  description = "The zone to host the VPC"
  type        = string
}

variable "instance_name" {
  description = "Name of the compute instance"
  type        = string
}

variable "instance_type" {
  description = "Machine type of the compute instance"
  type        = string
}

variable "image_family" {
  description = "Image family for the compute instance"
  type        = string
}

variable "boot_disk_type" {
  description = "Boot disk type for the compute instance"
  type        = string
}

variable "boot_disk_size" {
  description = "Boot disk size in GB for the compute instance"
  type        = number
}

variable "app_port" {
  description = "Application port to allow in firewall"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet for the instance"
  type        = string
}
variable "source_ranges" {
  description = "Source ranges for firewall rules"
  type        = list(string)
}
variable "routing_mode" {
  description = "The routing mode of the network"
  type        = string
  default     = "REGIONAL"
}

variable "dest_range" {
  description = "Destination range for the internet gateway route"
  type        = string
}
variable "private_ip_alloc_name" {
  description = "Name for the private IP allocation"
  type        = string
}

variable "private_ip_prefix_length" {
  description = "Prefix length for the private IP allocation"
  type        = number
}

variable "vpc_network_name" {
  description = "Name of the VPC network"
  type        = string
}
variable "deletion_protection" {
  description = "Indicates whether the instance should be protected from deletion"
  type        = bool
  default     = false
}

variable "availability_type" {
  description = "Specifies the availability type of the instance"
  type        = string
  default     = "REGIONAL"
}

variable "disk_type" {
  description = "Type of the storage disk"
  type        = string
  default     = "pd-ssd"
}

variable "disk_size" {
  description = "Size of the storage disk in GB"
  type        = number
  default     = 100
}

variable "ipv4_enabled" {
  description = "Boolean flag indicating if IPv4 is enabled"
  type        = bool
  default     = false
}
resource "random_string" "instance_suffix" {
  length  = 8
  special = false
  upper   = false
}

variable "dns_record_name" {
  description = "The DNS record name for the web app"
  type        = string
}

variable "dns_managed_zone_name" {
  description = "The name of the DNS managed zone"
  type        = string
}

variable "mailgun_from_mail_id" {
  description = "The email ID from which the mail is sent"
  type        = string
  default = "CSYE User Verification <mailgun@suryamadhav.me>"
}
variable "verification_link_base_url" {
  description = "The base URL for the verification link"
  type        = string
}
variable "mailgun_url" {
  description = "The mailgun URL"
  type        = string
}
variable "api_key" {
  description = "The API key for the mailgun service"
  type        = string
}

variable "service_account_email" {
  description = "value of the service account email"
  type        = string
}

variable "encryption_key_name" {
  description = "The name of the encryption key"
  type        = string
  
  
}
variable "encryption_key_name_vm" {
  description = "The name of the encryption key"
  type        = string
  
}