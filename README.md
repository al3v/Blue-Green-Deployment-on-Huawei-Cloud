# 🔵 Automating Blue-Green Deployment on Huawei Cloud with GitHub Actions 🟢

This repository contains scripts to perform a Blue-Green deployment on Huawei Cloud using Elastic Load Balancer (ELB). The scripts direct traffic between two backend servers, perform deployments, and ensure servers are healthy before switching traffic.

I tested this script on Huawei Cloud using an Elastic Load Balancer (ELB) with two backend Elastic Cloud Servers (ECS). Each ECS instance has Nginx installed, and the ELB health checks are configured to monitor port 80. This setup ensures that traffic can be directed to either server during deployment, validating the successful execution of the Blue-Green deployment strategy.

![Animation-ezgif com-speed](https://github.com/user-attachments/assets/60276630-1357-46fd-a253-9fb6bfd1e2b7)




## 📋 Prerequisites

- Huawei Cloud CLI (`hcloud`) must be installed and configured.
- Huawei Cloud Access Key and Secret Key
- An Elastic Load Balancer (ELB) setup with 2 backend servers.

## 📝 Script Details

### Variables

- `LOAD_BALANCER_ID`: The ID of your Elastic Load Balancer.
- `POOL_ID`: The ID of the backend server pool.
- `PROJECT_ID`: Your Huawei Cloud project ID.
- `REGION`: The region of your resources.
- `SERVER1_ID`: The ID of the first backend server.
- `SERVER2_ID`: The ID of the second backend server.

### Functions

- `update_backend_weight(member_id, weight)`: Updates the weight of a backend server.
- `check_server_health(member_id)`: Checks the health status of a backend server.

## 🚀 Deployment Steps

1. 🔀 Direct all traffic to the first server.
2. 🛠️ Deploy on the second server.
3. ⏳ Wait until the second server becomes healthy.
4. 🔀 Direct all traffic to the second server.
5. 🛠️ Deploy on the first server.
6. ⏳ Wait until the first server becomes healthy.
7. 🔄 Distribute the traffic to both servers equally.

## 📂 Usage

1. 📥 Clone this repository:

    ```bash
    https://github.com/al3v/Blue-Green-Deployment-on-Huawei-Cloud.git
    cd Blue-Green-Deployment-on-Huawei-Cloud
    ```

2. ✏️ Modify the script to set your own `LOAD_BALANCER_ID`, `POOL_ID`, `PROJECT_ID`, `REGION`, `SERVER1_ID`, and `SERVER2_ID`.

3. 🛠️ If you have trouble finding your pool ID, use the following command:

    ```bash
    hcloud elb ListPools/v3 \
      --project_id=<YOUR_PROJECT_ID> \
      --cli-region=<YOUR_REGION>
    ```
 - On the console, it is just Backend Server Group ID:

![image](https://github.com/user-attachments/assets/6ba38b88-91f0-4a90-b2aa-1a9c9c56bb73)

-----------------------------------------------
### PS: 

 Server IDS are different than ECS IDs but they are mapped, you can retrieve SERVER IDs via 'hcloud' :

 List Members in a specific Pool
 
```bash
hcloud elb ListMembers/v3 --pool_id=your_pool_id --project_id=your_project_id --cli-region=your_region
```

----------------------------------------

4. Choose the appropriate script for your environment:

    - 🐧 For Bash (Linux/macOS):
    
        ```bash
        ./blue-green-deploy.sh
        ```

    - 🪟 For PowerShell (Windows):
    
        ```powershell
        .\blue-green-deploy.ps1
        ```


## 📸 Real-Time Deployment Example

The following screenshot demonstrates the real-time weight change of the backend servers during deployment. The terminal output shows the JSON response indicating the operating status and weight of the backend servers, while the Huawei Cloud console reflects these changes in real-time:

![image](https://github.com/user-attachments/assets/467b16c1-cfd8-4907-af4e-4dfbd4963ae6)


In this example, you can see:
- The terminal displays the weight of `100` for the first server and `0` for the second server, indicating that all traffic is directed to the first server.
- The Huawei Cloud console reflects these weight settings, showing the same values for the backend servers.
- The script then proceeds to deploy on the second server, updating the weights accordingly and ensuring the health of the servers before switching traffic.


-----------------------------------------------------------------------------------------------------------

## 💻 Direct CLI Usage (OPTIONAL)

If you want to update the weights directly from the CLI, you can copy and paste the following commands:

```bash
# Update Weight for the First Server
hcloud elb UpdateMember/v3 \
  --pool_id=<YOUR_POOL_ID> \
  --member_id=<YOUR_FIRST_SERVER_ID> \
  --project_id=<YOUR_PROJECT_ID> \
  --member.weight=100 \
  --cli-region=<YOUR_REGION>

# Update Weight for the Second Server
hcloud elb UpdateMember/v3 \
  --pool_id=<YOUR_POOL_ID> \
  --member_id=<YOUR_SECOND_SERVER_ID> \
  --project_id=<YOUR_PROJECT_ID> \
  --member.weight=0 \
  --cli-region=<YOUR_REGION>

# Verify the Changes
hcloud elb ListMembers/v3 \
  --pool_id=<YOUR_POOL_ID> \
  --project_id=<YOUR_PROJECT_ID> \
  --cli-region=<YOUR_REGION>
```

-----------------------------------------------------------------------------------------------------------
