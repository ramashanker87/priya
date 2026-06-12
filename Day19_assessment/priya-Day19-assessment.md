Assignment 1: Containerization, Docker Compose, and Amazon ECS Deployment

Objective:
Build, containerize, and deploy 1st Python applications using Docker and Amazon ECS
Fargate.

Scenario:
You are provided with two simple Python applications. Each application must:
• Read the participant's name from an environment variable named PARTICIPANT_NAME.
• Display the participant name along with the application type.

Application 1 should print:
Hello <PARTICIPANT_NAME> from ECS Application

Application 2 should print:
Hello <PARTICIPANT_NAME> from EKS Application

Tasks:
Part A: Docker Image Creation
1. Create a Python application for ECS.
2. Create a Python application for EKS.
3. Write separate Dockerfiles for both applications.
4. Build Docker images for both applications.
5. Verify the applications run successfully using environment variables.

Part B: Local Testing with Docker Compose
1. Create a docker-compose.yml file.
2. Configure both containers to run simultaneously on a local machine.
3. Pass the PARTICIPANT_NAME environment variable to each container.
4. Demonstrate successful execution of both applications.

Part C: Amazon ECR
1. Create two Amazon ECR repositories: - ecs-app-repository - eks-app-repository
2. Tag the Docker images appropriately.
3. Push both images to their respective ECR repositories.

Part D: Amazon ECS Deployment
1. Create a CloudFormation template (ecs-cluster.yml) that provisions:
- ECS Cluster
- Task Definition
- ECS Service
- Fargate Networking Configuration
2. Deploy the ECS application using:
- Fargate Launch Type
- Desired Task Count = 2
3. Verify that two ECS tasks are running successfully.

Deliverables:
• Source code for ECS application
• Source code for EKS application
• Dockerfile for ECS application
• Dockerfile for EKS application
• docker-compose.yml
• ECS CloudFormation template (ecs-cluster.yml)
• Screenshots showing:
  - Local Docker Compose execution
  - ECR repositories
  - Running ECS tasks
• README.md with deployment instructions
==========================================================================
##Verify Installation

Check Docker Version:

```bash
docker --version
```

Check Service:

```bash
sudo systemctl status docker
```

Check Compose:

```bash
docker compose version
```
## PART-A:
===========================
## Create python application and Dockerfile for ECS (Application Name: priya-app1.py, Dockerfile name: Dockerfile-priya-1)
'''
import os

def main():
    # Read environment variable:
    participant_name = os.getenv('PARTICIPANT_NAME', "Guest")

    # Print Message
    print(f"Hello {participant_name} from ECS application")

if __name__ == "__main__":
    main()
'''
------------------------------------------------------------------
Creating Dockerfile in the name: Dockerfile-priya-1
'''
FROM python:3.12-slim
WORKDIR /app
COPY priya-app1.py .
EXPOSE 8080
CMD ["python","priya-app1.py"]
'''

## Create python application and Dockerfile for EKS (Application Name: priya-app1.py, Dockerfile name: Dockerfile-priya-2)
'''
import os

def main():
    # Read environment variable:
    participant_name = os.getenv('PARTICIPANT_NAME', "Guest")

    # Print Message
    print(f"Hello {participant_name} from EKS application")

if __name__ == "__main__":
    main()
'''
------------------------------------------------------------------
Creating Dockerfile in the name: Dockerfile-priya-2
'''
FROM python:3.12-slim
WORKDIR /app
COPY priya-app2.py .
EXPOSE 8080
CMD ["python","priya-app2.py"]
'''

# verify existing docker images
'''bash
docker images
if it gives: permission denied while trying to connect to the docker API at unix:///var/run/docker.sock

sudo usermod -aG docker $USER
newgrp docker

docker images
'''
=========================================================================================
#Build docker images for the both Applications:
Application-1:
```bash
docker build -f Dockerfile-priya-1 -t priya-python-app1-ecr:v1 .

expected Output:
IMAGE                                                       ID             DISK USAGE   CONTENT SIZE
priya-python-app1-ecr:v1                                    95e142a64756        177MB         43.2MB
```

Application-2:
'''bash
docker build -f Dockerfile-priya-2 -t priya-python-app2-ecr:v1 .

expected Output:
IMAGE                                                       ID             DISK USAGE   CONTENT SIZE
priya-python-app2-ecr:v1                                    3ea879eec5cb        177MB         43.2MB
'''
===========================================================================================
## Verify the applications run successfully using environment variables
'''bash
docker run -e PARTICIPANT_NAME=Priya priya-python-app1-ecr:v1
Expected output: Hello Priya from ECS application

docker run -e PARTICIPANT_NAME=Priya priya-python-app2-ecr:v1
expected Output: Hello Priya from EKS application
==============================================================================================
PART-B:
===========
docker-compose-priya.yml
'''yml
version: "3.8"

services:
  ecs-app:
    image: priya-python-app1-ecr:v1
    container_name: priya-ecs-app1
    environment:
      - PARTICIPANT_NAME=Priya
  eks-app:
      image: priya-python-app2-ecr:v1
      container_name: priya-eks-app2
      environment:
        - PARTICIPANT_NAME=Priya
'''
If file name is docker-compose.yml then run:
docker compose up

but my compose file name is: docker-compose-priya.yml so,
docker compose -f docker-compose-priya.yml up

Expected Output:
docker ps -a
CONTAINER ID   IMAGE                      COMMAND                  CREATED          STATUS                      PORTS     NAMES
31bdaa370edb   priya-python-app2-ecr:v1   "python priya-app2.py"   11 seconds ago   Exited (0) 10 seconds ago             priya-eks-app2
ac7fc5a720f3   priya-python-app1-ecr:v1   "python priya-app1.py"   11 seconds ago   Exited (0) 10 seconds ago             priya-ecs-app1
47dcd6ff9e6f   priya-python-app2-ecr:v1   "python priya-app2.py"   21 seconds ago   Exited (0) 20 seconds ago             vigorous_cohen
a8854b388749   priya-python-app1-ecr:v1   "python priya-app1.py"   30 seconds ago   Exited (0) 29 seconds ago             musing_lamport
===========================================================================
## PART-C:
-----------
## Create ECR Repository

```bash
aws ecr create-repository \
--repository-name priya-ecs-app-repository \
--region us-east-1 --profile devops
```

```bash
aws ecr create-repository \
--repository-name priya-eks-app-repository \
--region us-east-1 --profile devops
```
---

## Lab 7: Authenticate Docker

```bash
aws ecr get-login-password \
--region us-east-1 --profile devops | \
docker login \
--username AWS \
--password-stdin \
386757865964.dkr.ecr.us-east-1.amazonaws.com
```
========================================================
## Tag Image

```bash
docker tag priya-python-app1-ecr:v1 \
386757865964.dkr.ecr.us-east-1.amazonaws.com/priya-ecs-app-repository
```

```bash
docker tag priya-python-app2-ecr:v1 \
386757865964.dkr.ecr.us-east-1.amazonaws.com/priya-eks-app-repository
```
==============================================================
## Push Image to ECR

```bash
docker push \
386757865964.dkr.ecr.us-east-1.amazonaws.com/priya-ecs-app-repository
```

```bash
docker push \
386757865964.dkr.ecr.us-east-1.amazonaws.com/priya-eks-app-repository
```
## Verify Images in ECR repositories

```bash
aws ecr list-images \
--repository-name priya-ecs-app-repository \
--region us-east-1 --profile devops
```

```bash
aws ecr list-images \
--repository-name priya-eks-app-repository \
--region us-east-1 --profile devops
```
============================================================================================
PART:D:
-------
ECR image URI:

```text
386757865964.dkr.ecr.us-east-1.amazonaws.com/priya-ecs-app-repository:latest
```
```bash
aws cloudformation deploy \
  --stack-name priya-ecs-fargate-day19 \
  --template-file ecs-cluster-priya.yml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
      VpcId=vpc-0ca5b92e540035af6 \
      PublicSubnet1=subnet-02e4c0c0d48c6abe0 \
      PublicSubnet2=subnet-0fedff33455ac1bd6 \
      ECRImage=386757865964.dkr.ecr.us-east-1.amazonaws.com/priya-ecs-app-repository:latest \
  --profile devops
```

---

## 3. Get the Application URL

```bash
aws cloudformation describe-stacks \
  --stack-name priya-ecs-fargate-day19 \
  --query "Stacks[0].Outputs" \
  --profile devops
```

Open the `ApplicationURL` value in a browser.

---
##Assignment-2
Assignment 2: Kubernetes Deployment on Amazon EKS

Objective: Deploy a containerized Python application on Amazon EKS using Kubernetes manifests.

Scenario:
 Use the EKS application image created and stored in Amazon ECR during Assignment
 1. The application should:
 • Read the environment variable PARTICIPANT_NAME.
• Display: Hello <PARTICIPANT_NAME> from EKS Application

Tasks Part A: Amazon EKS Infrastructure
   1. Create a CloudFormation template (eks-cluster.yml) to provision:
   - Amazon EKS Cluster
   - Managed Node Group
   - One Worker Node
   2. Deploy the EKS cluster and verify node readines

Part B: Kubernetes Deployment
1. Create a Kubernetes Deployment manifest (deployment.yml) with:
   - Container image from Amazon ECR
   - Environment variable PARTICIPANT_NAME
   - Replica count = 2
2. Create a Kubernetes Service manifest (service.yml) to expose the application.
3. Apply both manifests to the EKS cluster.
4. Verify: - One worker node is available.
   - Two pods are running successfully.
   - Service is created successfully.


==========================================
```bash
cat > eks-cluster-trust-policy.json <<'JSON'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
JSON

aws iam create-role \
  --role-name eksClusterRole-priya \
  --assume-role-policy-document file://eks-cluster-trust-policy.json \
  --profile devops

aws iam attach-role-policy \
  --role-name eksClusterRole-priya \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy \
  --profile devops

export EKS_CLUSTER_ROLE_ARN=$(aws iam get-role \
  --role-name eksClusterRole-priya \
  --query 'Role.Arn' \
  --output text \
  --profile devops)

echo $EKS_CLUSTER_ROLE_ARN

Expected Output: arn:aws:iam::386757865964:role/eksClusterRole-priya
```
## AWS CLI

```bash
export VPC_ID=$(aws ec2 describe-vpcs \
  --filters Name=isDefault,Values=true \
  --query 'Vpcs[0].VpcId' \
  --output text \
  --region us-east-1 \
  --profile devops)

echo $VPC_ID
Expected output: Default VPC ID (vpc-0ca5b92e540035af6)

aws ec2 describe-subnets \
  --filters Name=vpc-id,Values=$VPC_ID \
  --query 'Subnets[*].[SubnetId,AvailabilityZone]' \
  --output table \
  --region us-east-1 \
  --profile devops

Expected Output:

--------------------------------------------
|              DescribeSubnets             |
+---------------------------+--------------+
|  subnet-02e4c0c0d48c6abe0 |  us-east-1f  |
|  subnet-0fedff33455ac1bd6 |  us-east-1d  |
|  subnet-03f49a7545ab39ca1 |  us-east-1e  |
|  subnet-057c5b756944172f6 |  us-east-1b  |
|  subnet-09c2eff8d6146d0e4 |  us-east-1c  |
|  subnet-011365086c4759545 |  us-east-1a  |
+---------------------------+--------------+

export SUBNET_IDS=$(aws ec2 describe-subnets \
  --filters  \
    Name=vpc-id,Values=$VPC_ID \
    Name=availability-zone,Values=us-east-1a,us-east-1b \
  --query 'Subnets[*].SubnetId' \
  --output text \
  --region us-east-1 \
  --profile devops)

echo $SUBNET_IDS
## Expected Output after filtering the subnets: subnet-057c5b756944172f6 subnet-011365086c4759545

## Create EKS Cluster
```bash
aws eks create-cluster \
  --name priya-day19-eks-cluster \
  --region us-east-1 \
  --role-arn $EKS_CLUSTER_ROLE_ARN \
  --resources-vpc-config subnetIds=$(echo $SUBNET_IDS | sed 's/ /,/g') \
  --profile devops
