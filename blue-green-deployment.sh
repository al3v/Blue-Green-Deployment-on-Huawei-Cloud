#!/bin/bash

# Variables
LOAD_BALANCER_ID="5ccc6ff6-6da8-45be-b330-854e4f3c0de2"
POOL_ID="260ff233-4be0-4134-bc1a-cd3625c85f7c"
PROJECT_ID="da9c89f493fb4554afab5f67a07ba4fd"
REGION="tr-west-1"

# Backend Server IDs
SERVER1_ID="4668b46f-7090-432c-a176-fcfa061e5179"  # Instance ID 99182496-11fa-4523-9ffc-3089c9fe88a1
SERVER2_ID="6e0ca664-ea72-4add-8fad-8a0a3cba2013"  # Instance ID d5554cf1-f9d3-46ec-9eef-8d128fe13308

# Function to update backend server weight
update_backend_weight() {
  local member_id=$1
  local weight=$2

  hcloud elb UpdateMember/v3 \
    --pool_id=$POOL_ID \
    --member_id=$member_id \
    --project_id=$PROJECT_ID \
    --member.weight=$weight \
    --cli-region=$REGION
}

# Function to check the health status of a server
check_server_health() {
  local member_id=$1
  local status=$(hcloud elb ListMembers/v3 \
    --pool_id=$POOL_ID \
    --project_id=$PROJECT_ID \
    --cli-region=$REGION | jq -r --arg member_id "$member_id" '.members[] | select(.id == $member_id) | .operating_status')

  echo $status
}

# Direct all traffic to the 1st server
update_backend_weight $SERVER1_ID 100
update_backend_weight $SERVER2_ID 0

# Deploy on the 2nd server
# Your deployment script here...
echo "Deploying on the 2nd server..."
sleep 10  # Simulate deployment time

# Wait until the 2nd server becomes healthy
while [[ "$(check_server_health $SERVER2_ID)" != "ONLINE" ]]; do
  echo "Waiting for the 2nd server to become healthy..."
  sleep 10
done

# Direct all traffic to the 2nd server
update_backend_weight $SERVER1_ID 0
update_backend_weight $SERVER2_ID 100

# Deploy on the 1st server
# Your deployment script here...
echo "Deploying on the 1st server..."
sleep 10  # Simulate deployment time

# Wait until the 1st server becomes healthy
while [[ "$(check_server_health $SERVER1_ID)" != "ONLINE" ]]; do
  echo "Waiting for the 1st server to become healthy..."
  sleep 10
done

# Distribute the traffic to both servers
update_backend_weight $SERVER1_ID 50
update_backend_weight $SERVER2_ID 50

echo "Blue-Green deployment completed successfully."
