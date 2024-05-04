<!--  want to write a detailed readme.md file for a project i worked on for  cloud networking course.
It has 3 folders:
1. CloudFunction
2. Terraform
3. Webapp

webapp has the code for node js express backend i built. It also has scripts for packer build. There are github actions which take care of running integration tests, compile and build checks, and packer format and validate and finally packer build. All the required variables are passed through github secrets.  
Terraform folder has code for setting up all the infrastructure as code on google cloud platform. 
CloudFunction has a code for creating a google cloud function which is used for triggering user verification mails. There also has github action for creating a zip file of the code and uploading it to the gcp bucket. 
 -->
 # Cloud Networking Project
 ## Abstract
    This project is a part of the Cloud Networking course. The project is a simple web application that allows users to register and login. The user receives a verification email upon registration. In this project, I have used Google Cloud Platform services like Cloud Functions, Cloud Storage, and Cloud SQL. The infrastructure is set up using Terraform. The backend is built using Node.js and Express. The project is deployed using GitHub Actions.
## Table of Contents
1. [Architecture And Design](#architecture-and-design)
2. [Webapp](#webapp)
3. [Terraform](#terraform)
4. [CloudFunction](#cloudfunction)
5. [CI/CD](#ci/cd)
6. [License](#license)
## Architecture And Design
## Webapp
## Terraform
## CloudFunction
## CI/CD
## License
Distributed under the MIT License. See `LICENSE` for more information.

