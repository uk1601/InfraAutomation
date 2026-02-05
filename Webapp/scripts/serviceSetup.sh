#!/bin/bash

LOG_FILE="/var/log/setup.log"

# Ensure log file exists and set permissions
sudo touch $LOG_FILE
sudo chmod 777 $LOG_FILE

# Logging function
log_and_exit() {
    message="ERROR: $1"
    echo "$message"
    echo "$message" >> $LOG_FILE
    logger -p user.error "$message"
    exit 1
}

log_info() {
    message="INFO: $1"
    echo "$message"
    echo "$message" >> $LOG_FILE
    logger -p user.info "$message"
}

log_error() {
    message="ERROR: $1"
    echo "$message"
    echo "$message" >> $LOG_FILE
    logger -p user.error "$message"
}

log_info "Starting setup script"

cd /opt/webapp/ || log_and_exit "Failed to change directory to /opt/webapp/"

log_info "Copying webapp.service to /etc/systemd/system/"
sudo cp /opt/webapp/scripts/webapp.service /etc/systemd/system/webapp.service || log_error "Failed to copy webapp.service to /etc/systemd/system"

echo "Creating user and group webapp..."
sudo groupadd -f webapp && \
sudo useradd -r -g webapp -s /usr/sbin/nologin webapp && \
sudo chown -R webapp:webapp /opt/webapp && \
sudo chmod -R 700 /opt/webapp || log_error "Failed to create user/group or set permissions"

log_info "Setting up /var/log/myapp"
sudo mkdir -p /var/log/myapp
sudo chown webapp:webapp /var/log/myapp

log_info "Copying Ops Agent config and restarting service"
sudo mkdir -p /etc/google-cloud-ops-agent
sudo cp /tmp/webapp/scripts/ops-agent-config.yaml /etc/google-cloud-ops-agent/config.yaml
sudo chown root:root /etc/google-cloud-ops-agent/config.yaml
sudo chmod 600 /etc/google-cloud-ops-agent/config.yaml
sudo systemctl restart google-cloud-ops-agent || log_error "Failed to restart google-cloud-ops-agent"

log_info "Setup script completed successfully"
sudo timedatectl set-timezone UTC || log_error "Failed to set timezone to UTC"
