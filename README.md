
# Terraform Project for GCP Infrastructure

This project contains Terraform configurations to set up networking infrastructure in Google Cloud Platform (GCP). It includes creating a Virtual Private Cloud (VPC), subnets, and necessary configurations for routing.

## Project Structure

- `main.tf`: Contains the main Terraform configuration for creating GCP resources.
- `variables.tf`: Defines the variables used in the Terraform configurations.
- `dev.tfvars`, `prod.tfvars`: Variable files for different environments (development, production).
- `.gitignore`: Specifies untracked files that Git should ignore (e.g., credentials, state files).

## Prerequisites

- Install [Terraform](https://www.terraform.io/downloads.html).
- Configure [Google Cloud SDK](https://cloud.google.com/sdk) and authenticate with GCP.

## Configuration

1. **Variables**: Customize your infrastructure by setting appropriate values in `dev.tfvars` and `prod.tfvars`. These files should include values for `gcp_project_id`, `gcp_region`, and optionally `gcp_credentials_file`.

2. **Provider Setup**: The GCP provider is configured to use the provided project ID, region, and credentials from the variable files.

## Running Terraform

Here are the key commands used in this project:

- **Initialize Terraform**:
  ```bash
  terraform init
  ```
  This command initializes the Terraform environment. It downloads the necessary Terraform providers and modules required for the configuration.

- **Plan Infrastructure**:
  ```bash
  terraform plan -var-file="dev.tfvars"
  ```
  Use this command to preview the changes Terraform will make for the development environment. This step is crucial to verify that the configuration will produce the desired results before any changes are actually made.

- **Apply Configuration**:
  ```bash
  terraform apply -var-file="dev.tfvars"
  ```
  This command applies the Terraform configuration to create resources in GCP. Replace `dev.tfvars` with `prod.tfvars` for the production environment. Terraform will provide a summary of the actions to be taken based on the configuration and will prompt for confirmation before proceeding.

- **Destroy Infrastructure**:
  ```bash
  terraform destroy -var-file="dev.tfvars"
  ```
  Use this command to tear down the infrastructure managed by Terraform. This is useful when you need to decommission resources that are no longer needed. As with `apply`, Terraform will show a plan of the resources to be destroyed and will ask for confirmation before proceeding.

## Best Practices

- **Version Control**: Keep all `.tf` and `.tfvars` files under version control (except for sensitive data).
- **Sensitive Data**: Do not include sensitive information (like credentials) in version control. Use environment variables or a secure vault system for such data.
- **Regular Updates**: Regularly update your Terraform files to reflect any changes in your infrastructure needs.

## Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Google Cloud Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
