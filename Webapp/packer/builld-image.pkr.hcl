variable "project_id" {
  type    = string
  default = ""
}

variable "source_image" {
  type    = string
  default = ""
}

variable "database_url" {
  type    = string
  default = ""
}

variable "zone" {
  type    = string
  default = ""
}

variable "ssh_username" {
  type    = string
  default = ""
}

packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}

source "googlecompute" "webapp" {
  project_id        = var.project_id
  source_image      = var.source_image
  zone              = var.zone
  image_name        = "webapp-custom-image-{{timestamp}}"
  image_family      = "node-mysql-app-family"
  image_description = "Custom image with Node.js and MySQL"
  ssh_username      = var.ssh_username
  network           = "default"
}

build {
  sources = ["source.googlecompute.webapp"]


  provisioner "file" {
    source      = "./webapp.zip"
    destination = "/tmp/"
  }

  provisioner "shell" {
    script = "./scripts/setup.sh"
  }

  provisioner "shell" {
    script = "./scripts/serviceSetup.sh"
  }
}
