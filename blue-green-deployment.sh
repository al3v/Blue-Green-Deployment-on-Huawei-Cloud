#!/bin/bash

# Variables
LOAD_BALANCER_ID=${LOAD_BALANCER_ID}
POOL_ID=${POOL_ID}
PROJECT_ID=${PROJECT_ID}
REGION=${REGION}

# Backend Server IDs
SERVER1_ID=${SERVER1_ID}
SERVER2_ID=${SERVER2_ID}

# Function to update backend server weight
function Update-BackendWeight {
    local MemberId=$1
    local Weight=$2

    hcloud elb UpdateMember/v3 \
        --pool_id=$POOL_ID \
        --member_id=$MemberId \
        --project_id=$PROJECT_ID \
        --member.weight=$Weight \
        --cli-region=$REGION
}

# Function to check the health status of a server
function Check-ServerHealth {
    local MemberId=$1

    status=$(hcloud elb ListMembers/v3 \
        --pool_id=$POOL_ID \
        --project_id=$PROJECT_ID \
        --cli-region=$REGION | jq -r ".members[] | select(.id==\"$MemberId\") | .operating_status")

    echo $status
}

# Direct all traffic to the 1st server
Update-BackendWeight $SERVER1_ID 100
Update-BackendWeight $SERVER2_ID 0

# Deploy on the 2nd server
echo "Deploying on the 2nd server..."
sleep 10  # Simulate deployment time

# Wait until the 2nd server becomes healthy
while [ "$(Check-ServerHealth $SERVER2_ID)" != "ONLINE" ]; do
    echo "Waiting for the 2nd server to become healthy..."
    sleep 10
done

# Direct all traffic to the 2nd server
Update-BackendWeight $SERVER1_ID 0
Update-BackendWeight $SERVER2_ID 100

# Deploy on the 1st server
echo "Deploying on the 1st server..."
sleep 10  # Simulate deployment time

# Wait until the 1st server becomes healthy
while [ "$(Check-ServerHealth $SERVER1_ID)" != "ONLINE" ]; do
    echo "Waiting for the 1st server to become healthy..."
    sleep 10
done

# Distribute the traffic to both servers
Update-BackendWeight $SERVER1_ID 50
Update-BackendWeight $SERVER2_ID 50

echo "Blue-Green deployment completed successfully."
