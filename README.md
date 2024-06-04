# Cloud Networking Project

## Abstract
This project is a part of the Cloud Networking course. It is a simple web application that allows users to register and log in. The user receives a verification email upon registration. In this project, I have used Google Cloud Platform services like Cloud Functions, Cloud Storage, and Cloud SQL. The infrastructure is set up using Terraform. The backend is built using Node.js and Express. The project is deployed using GitHub Actions.

## Table of Contents
1. [Architecture And Design](#architecture-and-design)
2. [Webapp](#webapp)
3. [Terraform](#terraform)
4. [CloudFunction](#cloudfunction)
5. [CI/CD](#cicd)
6. [License](#license)

## Architecture And Design
Describe the overall architecture of the project, including the design principles and patterns used. Explain how the different components interact with each other.

## Webapp
This directory contains the source code for the web application. The web app is built using [framework/language], and it allows users to register and log in. 

## Terraform
This directory includes the Terraform configuration files for setting up the necessary cloud infrastructure. The configurations include:
- VPC and Subnets
- Cloud SQL instance
- Cloud Storage bucket
- IAM roles and permissions

## CloudFunction
This directory contains the Google Cloud Functions used in the project. These functions handle backend tasks such as:
- User authentication
- Sending verification emails
- Processing user data

## CI/CD
The project uses GitHub Actions for Continuous Integration and Continuous Deployment. The CI/CD pipeline is configured to:
- Run tests on pull requests
- Deploy the application to Google Cloud on push to the main branch

## License
Distributed under the MIT License. See `LICENSE` for more information.
