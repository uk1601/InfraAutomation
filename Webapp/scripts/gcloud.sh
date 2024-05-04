#!/bin/bash

update_managed_instance_group() {
    local mig_name="YOUR_MIG_NAME"  # Replace with your actual MIG name
    local region="us-central1"  # Replace with the region of your MIG

    echo "Starting rolling update for MIG: $mig_name"
    if ! gcloud compute instance-groups managed rolling-action start-update $mig_name \
        --version template=$latest_template_name \
        --region $region; then
        echo "Failed to start rolling update for MIG: $mig_name. Trying fallback..."
        if [[ -n "$FALLBACK_UPDATE_MANAGED_INSTANCE_GROUP" ]]; then
            eval "$FALLBACK_UPDATE_MANAGED_INSTANCE_GROUP" || { echo "Fallback for updating MIG also failed. Exiting..."; return 1; }
        else
            echo "No fallback provided for updating MIG. Moving on..."
        fi
    else
        echo "Rolling update initiated for MIG: $mig_name."
    fi

    echo "Waiting for rolling update to complete for MIG: $mig_name"
    if ! gcloud compute instance-groups managed wait-until-stable $mig_name \
        --region $region \
        --timeout "30m"; then
        echo "Rolling update did not complete within the timeout for MIG: $mig_name. Moving on..."
    else
        echo "Rolling update completed successfully for MIG: $mig_name."
    fi
}

create_instance_template() {
    echo "Creating instance template..."
    if ! gcloud compute instance-templates create "app-instance-$(date +%s)" \
        --machine-type=e2-standard-2 \
        --tags=webapp,allow-lb \
        --boot-disk-auto-delete \
        --image-family="node-mysql-app-family" \
        --image-project="white-rune-413805" \
        --boot-disk-kms-key="${SA_KEY}" \
        --network-interface="network=projects/white-rune-413805/global/networks/dev-vpc,subnet=projects/white-rune-413805/regions/us-central1/subnetworks/dev-webapp,no-address" \
        --service-account="${SA_EMAIL}" \
        --scopes="https://www.googleapis.com/auth/cloud-platform,userinfo-email,compute-ro,storage-ro,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/pubsub" \
        --metadata=startup-script="$(<./scripts/startup.sh)",db_user="${DB_USER}",db_password="${DB_PASSWORD}",db_host="${DB_HOST}"; then
        echo "Failed to create instance template. Trying fallback..."
        if [[ -n "$FALLBACK_CREATE_INSTANCE_TEMPLATE" ]]; then
            eval "$FALLBACK_CREATE_INSTANCE_TEMPLATE" || { echo "Fallback for creating instance template also failed. Exiting..."; return 1; }
        else
            echo "No fallback provided for creating instance template. Moving on..."
        fi
    else
        echo "Instance template created successfully."
    fi
}

# Main execution
latest_template_name=$(gcloud compute instance-templates list \
  --filter="name:app-instance-*" \
  --sort-by=~creationTimestamp \
  --limit=1 \
  --format="value(name)")
echo "Latest template name: $latest_template_name"

echo "DB Host: $DB_HOST"
echo "DB Password: $DB_PASSWORD"
echo "DB User: $DB_USER"

LATEST_IMAGE=$(gcloud compute images describe-from-family node-mysql-app-family --project=white-rune-413805 --format="value(selfLink)")
echo "Latest Image: $LATEST_IMAGE"

create_instance_template
update_managed_instance_group
