#!/bin/bash

LOG_FILE="/var/log/setup.log"
sudo touch $LOG_FILE
sudo chmod 777 $LOG_FILE

log_and_exit() {
    echo "$1" | sudo tee -a $LOG_FILE
    logger -p user.error "$1"
    echo "Displaying the log content:"
    cat $LOG_FILE  # Print the content of the log file
    exit 1
}

write_log() {
    echo "$1" | sudo tee -a $LOG_FILE
    logger -p user.info "$1"
}

install_package() {
    write_log "Installing $1..."
    sudo yum install -y $1 >>$LOG_FILE 2>&1 || log_and_exit "Failed to install $1. Check $LOG_FILE for details."
}
write_log "Installing Google Cloud Ops Agent..."
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh >>$LOG_FILE 2>&1
sudo bash add-google-cloud-ops-agent-repo.sh --also-install >>$LOG_FILE 2>&1 || log_and_exit "Failed to install Google Cloud Ops Agent. Check $LOG_FILE for details."
# install_package "google-cloud-ops-agent"
# write_log "Installing Google Cloud Ops Agent..."
# curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh >>$LOG_FILE 2>&1
# sudo bash add-google-cloud-ops-agent-repo.sh --also-install >>$LOG_FILE 2>&1 || log_and_exit "Failed to add and install Google Cloud Ops Agent. Check $LOG_FILE for details."

# write_log "Installing Google Cloud Monitoring Agent..."
# curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh >>$LOG_FILE 2>&1
# sudo bash add-monitoring-agent-repo.sh >>$LOG_FILE 2>&1 || log_and_exit "Failed to add Monitoring agent repo. Check $LOG_FILE for details."
# install_package "stackdriver-agent"

# write_log "Installing Google Cloud Logging Agent..."
# curl -sSO https://dl.google.com/cloudagents/add-logging-agent-repo.sh >>$LOG_FILE 2>&1
# sudo bash add-logging-agent-repo.sh >>$LOG_FILE 2>&1 || log_and_exit "Failed to add Logging agent repo. Check $LOG_FILE for details."
# install_package "google-fluentd google-fluentd-catch-all-config-structured"

write_log "Installing zip..."
install_package "zip"
install_package "stress-ng"


# Enable and start the agents
# for agent_service in stackdriver-agent google-fluentd; do
#     write_log "Enabling $agent_service to start on boot..."
#     sudo systemctl enable $agent_service >>$LOG_FILE 2>&1 || log_and_exit "Failed to enable $agent_service. Check $LOG_FILE for details."
    
#     write_log "Starting $agent_service..."
#     sudo systemctl restart $agent_service >>$LOG_FILE 2>&1 || log_and_exit "Failed to start $agent_service. Check $LOG_FILE for details."
# done

write_log "All agents installed and started successfully."

cd /tmp
write_log "Unzipping webapp.zip..."
sudo unzip webapp.zip -d /tmp/webapp >>$LOG_FILE 2>&1 || log_and_exit "Failed to unzip webapp.zip. Check $LOG_FILE for details."

write_log "Creating .env file..."
# The echo statements related to DATABASE_URL and the content of .env are redirected to the log file.
echo "DATABASE_URL value: $DATABASE_URL" >> $LOG_FILE
sudo cat /tmp/webapp/.env >> $LOG_FILE
sudo cp -r /tmp/webapp /opt/ >>$LOG_FILE 2>&1

cd /opt/webapp || log_and_exit "Failed to navigate to /opt/webapp. Check $LOG_FILE for details."

write_log "Installing Node.js..."
curl -sL https://rpm.nodesource.com/setup_18.x | sudo bash - >>$LOG_FILE 2>&1
sudo yum install -y nodejs >>$LOG_FILE 2>&1 || log_and_exit "Failed to install Node.js. Check $LOG_FILE for details."

write_log "Node.js installation successful"
node --version >> $LOG_FILE
npm --version >> $LOG_FILE

write_log "Running npm install..."
sudo npm install >>$LOG_FILE 2>&1 || log_and_exit "npm install failed. Check $LOG_FILE for details."

write_log "Setup script completed successfully"
