#! /bin/bash
        
    write_log() {
    echo "$1" >> /var/log/my-startup-log.log
    }

    write_log "-------------------"
    write_log "Starting instance setup script."
    
    # Accessing metadata for database configuration
    write_log "Fetching database configuration metadata..."

    DB_USER=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/db_user)
    DB_PASSWORD=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/db_password)
    DB_HOST=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/db_host)

    if [[ -z "$DB_USER" || -z "$DB_PASSWORD" || -z "$DB_HOST" ]]; then
        write_log "Error fetching database configuration metadata."
    else
        write_log "Database configuration metadata fetched successfully."
    fi

    write_log "DB_USER: $DB_USER"
    write_log "DB_PASSWORD: $DB_PASSWORD" # Be cautious about logging sensitive info like passwords.
    write_log "DB_HOST: $DB_HOST"

    # Store environment variables to be loaded at system startup
    echo "export DB_USER=$DB_USER" | sudo tee /etc/profile.d/webapp_env.sh > /dev/null
    echo "export DB_PASSWORD=$DB_PASSWORD" | sudo tee -a /etc/profile.d/webapp_env.sh > /dev/null
    echo "export DB_HOST=$DB_HOST" | sudo tee -a /etc/profile.d/webapp_env.sh > /dev/null
    echo "export DATABASE_URL=mysql://$DB_USER:$DB_PASSWORD@$DB_HOST:3306/webapp" | sudo tee -a /etc/profile.d/webapp_env.sh > /dev/null
    
    echo "sudo chmod -R 777 /opt/webapp" | sudo tee -a /etc/profile.d/webapp_env.sh > /dev/null
    cd /opt/webapp
    echo "DB_USER=$DB_USER" > /opt/webapp/.env
    echo "DB_PASSWORD=$DB_PASSWORD" >> /opt/webapp/.env
    echo "DB_HOST=$DB_HOST" >> /opt/webapp/.env
    echo "DATABASE_URL=mysql://$DB_USER:$DB_PASSWORD@$DB_HOST:3306/webapp" >> /opt/webapp/.env

    write_log "$(ls -al)"
    write_log "$(cat /opt/webapp/.env)"

    write_log "Environment variables stored for system-wide use."
    sudo npm install -g prisma
    sudo npx prisma generate
    sudo npx prisma db push
    sudo chown -R webapp:webapp /opt/webapp
    sudo chmod -R 700 /opt/webapp
    

    # Ensure the script is executable
    sudo chmod +x /etc/profile.d/webapp_env.sh

    if [ $? -eq 0 ]; then
        write_log ".env file created successfully."
    else
        write_log "Failed to create .env file."
    fi

    write_log "Instance setup script completed."
    write_log "-------------------"

    write_log "Reloading systemd daemon..."
    sudo systemctl daemon-reload || log_error "Failed to reload systemd daemon"

    write_log "Enabling webapp service..."
    sudo systemctl enable webapp.service
        
    write_log "Starting and checking the status of webapp service..."
    sudo systemctl start webapp.service && sudo systemctl status webapp.service || log_error "Failed to start webapp service"
