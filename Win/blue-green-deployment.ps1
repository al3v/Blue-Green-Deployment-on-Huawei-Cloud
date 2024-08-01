# Variables
$LOAD_BALANCER_ID = "5ccc6ff6-6da8-45be-b330-854e4f3c0de2"
$POOL_ID = "260ff233-4be0-4134-bc1a-cd3625c85f7c"
$PROJECT_ID = "da9c89f493fb4554afab5f67a07ba4fd"
$REGION = "tr-west-1"

# Backend Server IDs
$SERVER1_ID = "4668b46f-7090-432c-a176-fcfa061e5179"  # Instance ID 99182496-11fa-4523-9ffc-3089c9fe88a1
$SERVER2_ID = "6e0ca664-ea72-4add-8fad-8a0a3cba2013"  # Instance ID d5554cf1-f9d3-46ec-9eef-8d128fe13308

# Function to update backend server weight
function Update-BackendWeight {
    param (
        [string]$MemberId,
        [int]$Weight
    )

    hcloud elb UpdateMember/v3 `
        --pool_id=$POOL_ID `
        --member_id=$MemberId `
        --project_id=$PROJECT_ID `
        --member.weight=$Weight `
        --cli-region=$REGION
}

# Function to check the health status of a server
function Check-ServerHealth {
    param (
        [string]$MemberId
    )

    $status = hcloud elb ListMembers/v3 `
        --pool_id=$POOL_ID `
        --project_id=$PROJECT_ID `
        --cli-region=$REGION | ConvertFrom-Json

    $member = $status.members | Where-Object { $_.id -eq $MemberId }
    return $member.operating_status
}

# Direct all traffic to the 1st server
Update-BackendWeight -MemberId $SERVER1_ID -Weight 100
Update-BackendWeight -MemberId $SERVER2_ID -Weight 0

# Deploy on the 2nd server
# Your deployment script here...
Write-Host "Deploying on the 2nd server..."
Start-Sleep -Seconds 10  # Simulate deployment time

# Wait until the 2nd server becomes healthy
while ((Check-ServerHealth -MemberId $SERVER2_ID) -ne "ONLINE") {
    Write-Host "Waiting for the 2nd server to become healthy..."
    Start-Sleep -Seconds 10
}

# Direct all traffic to the 2nd server
Update-BackendWeight -MemberId $SERVER1_ID -Weight 0
Update-BackendWeight -MemberId $SERVER2_ID -Weight 100

# Deploy on the 1st server
# Your deployment script here...
Write-Host "Deploying on the 1st server..."
Start-Sleep -Seconds 10  # Simulate deployment time

# Wait until the 1st server becomes healthy
while ((Check-ServerHealth -MemberId $SERVER1_ID) -ne "ONLINE") {
    Write-Host "Waiting for the 1st server to become healthy..."
    Start-Sleep -Seconds 10
}

# Distribute the traffic to both servers
Update-BackendWeight -MemberId $SERVER1_ID -Weight 50
Update-BackendWeight -MemberId $SERVER2_ID -Weight 50

Write-Host "Blue-Green deployment completed successfully."
