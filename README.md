# InfraAutomation

## Abstract
This project is developed as part of the CSYE 6225: Network Structures and Cloud Computing course at Northeastern University. It leverages cloud-native concepts to build a scalable, automated infrastructure using Google Cloud Platform (GCP), Terraform, and other modern tools. The project focuses on deploying a RESTful API, handling user authentication, and automating infrastructure setup, all while adhering to best practices in security, monitoring, and CI/CD.

## Table of Contents
1. [Architecture and Design](#architecture-and-design)
2. [Web Application](#web-application)
3. [Infrastructure as Code](#infrastructure-as-code)
4. [Google Cloud Platform Networking](#google-cloud-platform-networking)
5. [Custom Machine Image](#custom-machine-image)
6. [Database Configuration](#database-configuration)
7. [Monitoring and Logging](#monitoring-and-logging)
8. [Event-Driven Architecture](#event-driven-architecture)
9. [Load Balancing and Autoscaling](#load-balancing-and-autoscaling)
10. [Security and Encryption](#security-and-encryption)
11. [Continuous Deployment](#continuous-deployment)
12. [License](#license)

## Architecture and Design
The project adopts a cloud-native architecture, emphasizing modularity and scalability. Key components include:
- **Microservices**: Decoupled services for handling user authentication, data storage, and background processing.
- **RESTful API**: Built with Node.js and Sequelize, ensuring robust and secure endpoints.
- **Infrastructure as Code (IaC)**: Managed using Terraform for consistent and repeatable deployments.

## Web Application
A cloud-native RESTful API designed for user management and health checks, implemented with:
- **Node.js and Sequelize**: For API endpoints like `/healthz` and `/v1/user`.
- **Basic Authentication**: Securely accessing endpoints using hashed passwords and tokens.
- **Integration Tests**: Ensuring endpoint functionality within CI pipelines.

## Infrastructure as Code
Terraform scripts automate the provisioning of GCP resources:
- **VPC and Subnets**: Configured for network isolation.
- **Cloud SQL**: Private instance for secure data storage.
- **IAM Roles**: Managed access to cloud resources.

## Google Cloud Platform Networking
Setup includes:
- **VPC and Subnets**: Created using Terraform.
- **Firewall Rules**: Defined for securing network traffic.

## Custom Machine Image
Custom Centos Stream 8 image created using Hashicorp Packer:
- **Pre-installed Software**: Ensures consistency across deployments.
- **Systemd Service**: Manages RESTful API application startup.
- **Built in CI**: Image creation integrated with GitHub Actions.

## Database Configuration
Configured with Terraform:
- **Private CloudSQL Instance**: Secure communication via private IP.
- **Startup Script**: Generates `.env` file with database credentials.

## Monitoring and Logging
Ensures application health and performance:
- **Ops Agent**: Collects application logs.
- **Winston Library**: Generates logs for analysis.

## Event-Driven Architecture
Utilizes Google Pub/Sub for messaging:
- **Publisher**: RESTful API publishes messages upon user creation.
- **Subscriber**: Cloud Function sends verification emails.

## Load Balancing and Autoscaling
Handles traffic efficiently:
- **Compute Instance Template**: Based on custom image.
- **Managed Instance Group**: Autoscaling based on CPU utilization.
- **External Application Load Balancer**: Distributes traffic across instances.
- **SSL Certificates**: Managed by Google for secure communication.

## Security and Encryption
Enhances data protection:
- **Customer-Managed Encryption Keys (CMEK)**: Controls encryption lifecycle.
- **30-Day Rotation**: Regular key updates for enhanced security.

## Continuous Deployment
Automates updates:
- **Rolling Updates**: Gradual deployment of new versions.
- **CI Pipeline**: Integrated with GitHub Actions for seamless deployments.

## License
Distributed under the MIT License. See `LICENSE` for more information.

---
