# InfraAutomation

## Overview

A scalable, cloud-native web application on **Google Cloud Platform (GCP)**. It uses **Infrastructure as Code (Terraform)**, a custom machine image (**Packer**), a **Node.js/TypeScript** REST API with **Prisma** and **MySQL**, and **event-driven** email verification via **Pub/Sub** and **Cloud Functions**. The system covers networking, compute, database, load balancing, CI/CD, and observability.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Repository Structure](#repository-structure)
3. [High-Level Flows](#high-level-flows)
4. [Web Application](#web-application)
5. [Infrastructure (Terraform)](#infrastructure-terraform)
6. [Custom Machine Image (Packer)](#custom-machine-image-packer)
7. [Event-Driven Email Verification](#event-driven-email-verification)
8. [Load Balancing and Autoscaling](#load-balancing-and-autoscaling)
9. [CI/CD Pipelines](#cicd-pipelines)
10. [Security and Operations](#security-and-operations)
11. [License](#license)

---

## Architecture Overview

- **API**: REST API (Express + TypeScript) for user management and health checks.
- **Data**: MySQL (GCP Cloud SQL) with private IP; access via VPC.
- **Compute**: GCE instances from a **custom Packer image**, running behind an **external Application Load Balancer** with a **Managed Instance Group** and autoscaling.
- **Events**: User signup triggers a **Pub/Sub** message; a **Cloud Function** sends a verification email (Mailgun) and writes to a **MailLog** table.
- **DNS**: Cloud DNS A record for the app; MX/TXT/CNAME for Mailgun (email domain).
- **IaC**: Terraform for VPC, subnets, firewall, Cloud SQL, Pub/Sub, Cloud Function, VPC connector, load balancer, health checks, instance template, MIG, autoscaler, DNS, and service accounts.

---

## Repository Structure

```
InfraAutomation/
├── README.md                 # This file
├── Terraform/                # GCP infrastructure (VPC, Cloud SQL, LB, MIG, etc.)
├── Webapp/                   # Node.js/TypeScript API and Packer image
└── CloudFunction/            # Pub/Sub-triggered verification email function
```

- **Terraform**: All GCP resources (networking, database, Pub/Sub, function, load balancer, MIG, DNS, IAM).
- **Webapp**: Express app, Prisma schema, routes, services, middleware, tests, Packer HCL, and scripts (setup, systemd, Ops Agent).
- **CloudFunction**: Node.js function triggered by `verify_email` Pub/Sub topic; sends email and logs to MySQL.

---

## High-Level Flows

### 1. Request flow (user-facing traffic)

1. Client → **HTTPS (443)** → Global forwarding rule (static IP).
2. **Target HTTPS proxy** (with managed SSL cert) → **URL map** → **Backend service**.
3. Backend service → **HTTP (3000)** to instances in the MIG (tagged `allow-lb`).
4. **Health check** (`/healthz` on port 3000) determines instance health; unhealthy instances are recreated.
5. App on each VM connects to **Cloud SQL** via **private IP** (same VPC).

### 2. User signup and email verification flow

1. Client **POST /v1/user** (username, password, first_name, last_name).
2. **Validation** (email format, required fields) → **UserService** creates user in DB (bcrypt password), then **publishes** to Pub/Sub topic `verify_email` with `{ email, userId }`.
3. **Cloud Function** (triggered by `verify_email`) receives message, calls **Mailgun** to send verification email with link `{verification_link_base_url}/verification?token={userId}`.
4. Function connects to Cloud SQL (via VPC connector) and **inserts** into **MailLog** (email, userId, verificationLink, status, errorMessage).
5. User clicks link → **GET /verification?token=...** → **UserService.verifyUserAccount** checks user exists, checks MailLog and 2-minute window, then sets **users.isVerified = true**.

### 3. Deployment and image flow

1. **Webapp**: On merge to `main`, CI runs tests, builds app, zips artifact, builds **Packer image** (from base image + app zip + setup scripts + Ops Agent + systemd). Image family: `node-mysql-app-family`.
2. **Terraform** (or separate pipeline) uses `data.google_compute_image` (latest from that family) in **instance template**; **MIG** uses that template. New instances run **startup script** that reads DB credentials from metadata, writes `.env`, runs Prisma generate/push, starts **webapp.service**.
3. **Cloud Function** code is zipped and uploaded to GCS; Terraform deploys the function with event trigger on `verify_email` and env vars (DB, Mailgun, base URL).

---

## Web Application

- **Stack**: Node.js 18, TypeScript, Express, Prisma (MySQL), bcrypt, JWT (for token generation), Winston (logging), class-validator (validation).
- **Endpoints**:
  - **GET /healthz**: Health check; no body/query; returns 200 if DB connection succeeds, 503 otherwise; 400 for invalid request.
  - **POST /v1/user**: Create user (validation middleware); returns 201 + user payload (no password); publishes to Pub/Sub.
  - **GET /v1/user/self**: Get current user (Basic auth); requires verified account.
  - **PUT /v1/user/self**: Update user (Basic auth); username immutable; requires verified account.
  - **GET /verification?token=...**: Verify account using token (userId); 2-minute window from MailLog.sentAt.
- **Auth**: Basic auth (username/password); auth middleware loads user from DB and compares password with bcrypt.
- **Data**: Prisma schema defines **User** (id, username, firstName, lastName, password, isVerified, accountCreated, accountUpdated) and **MailLog** (email, userId, verificationLink, sentAt, status, errorMessage). App uses **DATABASE_URL** from `.env` (built at VM startup from instance metadata).

---

## Infrastructure (Terraform)

- **Provider**: `hashicorp/google` ~> 5.24; config in `provider.tf`; variables in `variables.tf`.
- **main.tf**: VPC (no auto subnets), subnets (from `var.subnets`), default internet route, firewall (app port + 22; source: LB IP ranges + health check IPs; target tag `webapp`), data source for latest custom image (`var.image_family`), Service Networking API, private IP allocation, **private VPC peering** for Cloud SQL.
- **cloudsql.tf**: Cloud SQL MySQL 5.7 instance (private IP only), database `webapp`, user `webapp`, random password; disk/settings/backup as per variables.
- **loadbalencer.tf**: Static IP, firewall for LB → instances (ports 3000, 8443, 22; target tag `allow-lb`), backend service (HTTP, health check, MIG), managed SSL cert (domain from `var.dns_record_name`), HTTPS proxy, global forwarding rule (443).
- **autoscaler.tf**: Instance template (custom image, metadata with db_user/db_password/db_host, startup script from `startup.sh`, service account with logging/monitoring/pubsub), health check (HTTP `/healthz` on 3000), MIG with template and auto-healing, autoscaler (CPU target, min/max replicas).
- **dns.tf**: A record for app → LB IP; MX, TXT, DKIM, CNAME for Mailgun domain (e.g. `udaykirandasari.me`).
- **event.tf**: Pub/Sub topic `verify_email`, VPC access connector for Cloud Function, Cloud Function (Node 20, triggered by topic, env: DB credentials, Mailgun, verification base URL, API key).
- **serviceAccounts.tf**: Ops Agent service account with roles: logging.admin, pubsub.publisher, monitoring.metricWriter.
- **keyRing.tf**: Commented-out KMS/CMEK (optional for Cloud SQL and VM disk encryption).
- **startup.sh** (Terraform): Used as instance metadata startup script; reads db_user/db_password/db_host from metadata, writes `/opt/webapp/.env` and profile script, runs prisma generate + db push, enables/starts `webapp.service`.

---

## Custom Machine Image (Packer)

- **File**: `Webapp/packer/builld-image.pkr.hcl`.
- **Source**: GCE image (e.g. CentOS) from variables; outputs image in family **node-mysql-app-family**.
- **Build**: Copies `webapp.zip` to VM; runs `scripts/setup.sh` (Ops Agent, zip, unzip app, Node 18, npm install) and `scripts/serviceSetup.sh` (user `csye6225`, systemd unit, Ops Agent config, timezone).
- **Result**: Image has app at `/opt/webapp`, systemd unit `webapp.service` (runs `node dist/src/index.js` after `.env` exists), Ops Agent reading `/var/log/myapp/application.log`. At boot, Terraform’s **startup.sh** injects DB config and runs Prisma; then systemd starts the app.

---

## Event-Driven Email Verification

- **Topic**: `verify_email` (Terraform).
- **Publisher**: Webapp `UserService` after creating user; payload `{ email, userId }`.
- **Subscriber**: Cloud Function `helloPubSub` (Node 20); decodes message, builds verification URL, sends email via Mailgun, then connects to Cloud SQL (same VPC via connector) and inserts into **MailLog**. Function env: db_* from Terraform (Cloud SQL user/password/private IP), Mailgun URL, API key, from address, verification base URL.

---

## Load Balancing and Autoscaling

- **External Application Load Balancer**: Global static IP → HTTPS (443) → backend service → MIG instances (port 3000).
- **Health check**: HTTP GET `/healthz` every 25s; unhealthy threshold 2; auto-healing replaces bad instances.
- **Autoscaler**: CPU-based (e.g. target 5%), min/max replicas, cooldown.
- **Instance template**: Custom image, metadata and startup script for DB and Prisma; tagged `webapp` and `allow-lb`.

---

## CI/CD Pipelines

- **Webapp**
  - **Node.js CI** (PR to main): Install, build (no tests in snippet; can be extended).
  - **Integration tests** (PR): MySQL service, Prisma, `DATABASE_URL` secret, `npm test`.
  - **Packer validate** (PR): Packer init, fmt check, validate with variables from secrets.
  - **Packer build** (PR closed + merged): Integration tests, build, zip, auth to GCP, Packer build; produces new image in family.
  - **Instance group** (PR closed): GCP auth, run `scripts/gcloud.sh` to create/update instance template and MIG rolling update (uses secrets for DB, SA, region, etc.).
- **CloudFunction**
  - **Deploy to GCS** (push to main): Zip code, upload to GCS bucket (bucket name and credentials via secrets). Terraform deploys the function from that object.

---

## Security and Operations

- **Network**: App and DB in same VPC; Cloud SQL private IP only; firewall by tags and LB/IP ranges.
- **Secrets**: DB password from Terraform `random_password`; Mailgun API key and similar in Terraform variables (or secret manager in production).
- **IAM**: Dedicated service account for Ops Agent (logging, monitoring, pubsub); instance template uses this SA.
- **Logging**: Winston to `/var/log/myapp/application.log`; Ops Agent (config in `scripts/ops-agent-config.yaml`) parses JSON and sends to Cloud Logging.
- **Optional**: keyRing.tf has commented CMEK for Cloud SQL and VM disks; can be enabled and variables set.

---

## License

Distributed under the MIT License. See `LICENSE` for details.
