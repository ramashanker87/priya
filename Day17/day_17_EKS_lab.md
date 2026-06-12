# Day 17 - EKS Lab: Create an Amazon EKS Cluster and Deploy an Image from ECR

## Goal

Create an Amazon EKS cluster and deploy the Docker image already pushed to Amazon ECR:

```text
386757865964.dkr.ecr.us-east-1.amazonaws.com/priya-ecr:v2
```

This lab includes both methods for each major task:

- AWS Management Console steps
- AWS CLI commands

## Lab Values

```bash
export AWS_REGION=us-east-1
export AWS_ACCOUNT_ID=386757865964
export CLUSTER_NAME=rama-eks-cluster
export NODEGROUP_NAME=rama-eks-nodegroup
export ECR_REPO=rama-ecr
export IMAGE_TAG=v2
export IMAGE_URI=386757865964.dkr.ecr.us-east-1.amazonaws.com/rama-ecr:v2
export NAMESPACE=day17
export APP_NAME=rama-ecr-app
```

---

## Prerequisites

You need AWS permissions for EKS, IAM, VPC, EC2, ECR, and Load Balancer resources. Use AWS CloudShell or a local machine with AWS CLI, kubectl, and Docker if image push is required.

---

# Step 1 - Configure AWS CLI

## Console

1. Open AWS Console.
2. Select region **N. Virginia / us-east-1**.
3. Open **CloudShell** from the top navigation bar.

## AWS CLI

```bash
aws sts get-caller-identity --profile devops
```

---

# Step 2 - Verify or Create ECR Repository

## Console

1. Go to **Amazon ECR > Private repositories**.
2. Check if repository **rama-ecr** exists.
3. Open the repository and confirm image tag **v2** exists.
4. If missing, click **Create repository**, choose **Private**, enter `priya-ecr`, and create it.

## AWS CLI

```bash
aws ecr describe-repositories \
  --repository-names priya-ecr \
  --region us-east-1 \
  --profile devops
```

Create repository if it does not exist:

## Lab 6: Create ECR Repository

```bash
aws ecr create-repository \
--repository-name priya-ecr \
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


## Lab 9: Push Image to ECR

```bash
docker push \
386757865964.dkr.ecr.us-east-1.amazonaws.com/priya-ecr:v2
```

## Verify images

```bash
aws ecr describe-images \
  --repository-name priya-ecr \
  --image-ids imageTag=v2 \
  --region us-east-1 \
  --profile devops
```
---

# Step 4 - Create EKS Cluster IAM Role

## Console

1. Go to **IAM > Roles > Create role**.
2. Trusted entity type: **AWS service**.
3. Use case: **EKS**.
4. Choose **EKS - Cluster**.
5. Attach policy `AmazonEKSClusterPolicy`.
6. Role name: `eksClusterRole`.
7. Create role.

## AWS CLI

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

Expected Output: arn:aws:iam::386757865964:role/eksClusterRole
```

---

# Step 5 - Select VPC and Subnets

For a lab, use the default VPC with at least two subnets in different Availability Zones.

## Console

1. Go to **VPC > Your VPCs**.
2. Confirm a default VPC exists in `us-east-1`.
3. Go to **Subnets**.
4. Select at least two subnets from different Availability Zones.
5. Save the subnet IDs.

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

## Expected Output:
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
```

---

# Step 6 - Create EKS Cluster

## Console

1. Go to **Amazon EKS > Clusters**.
2. Click **Create cluster**.
3. Cluster name: `rama-eks-cluster`.
4. Select latest stable Kubernetes version.
5. Cluster service role: `eksClusterRole`.
6. Select your VPC and subnets.
7. Endpoint access: public for lab use, or public/private as required.
8. Review and create cluster.
9. Wait until status is **Active**.

## AWS CLI

```bash
aws eks create-cluster \
  --name priya-day19-eks-cluster \
  --region us-east-1 \
  --role-arn $EKS_CLUSTER_ROLE_ARN \
  --resources-vpc-config subnetIds=$(echo $SUBNET_IDS | sed 's/ /,/g') \
  --profile devops

aws eks wait cluster-active \
  --name priya-day19-eks-cluster \
  --region us-east-1 \
  --profile devops

aws eks describe-cluster \
  --name priya-day19-eks-cluster \
  --region us-east-1 \
  --query 'cluster.status' \
  --profile devops
```

---

# Step 7 - Create Node Group IAM Role

## Console

1. Go to **IAM > Roles > Create role**.
2. Trusted entity type: **AWS service**.
3. Use case: **EC2**.
4. Attach these policies:
   - `AmazonEKSWorkerNodePolicy`
   - `AmazonEC2ContainerRegistryReadOnly`
   - `AmazonEKS_CNI_Policy`
5. Role name: `eksNodeGroupRole`.
6. Create role.

## AWS CLI

```bash
cat > eks-nodegroup-trust-policy.json <<'JSON'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
JSON

aws iam create-role \
  --role-name eksNodeGroupRole-priya \
  --assume-role-policy-document file://eks-nodegroup-trust-policy.json \
  --profile devops

aws iam attach-role-policy \
  --role-name eksNodeGroupRole-priya \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy \
  --profile devops

aws iam attach-role-policy \
  --role-name eksNodeGroupRole-priya \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly \
  --profile devops

aws iam attach-role-policy \
  --role-name eksNodeGroupRole-priya \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
  --profile devops

export EKS_NODE_ROLE_ARN=$(aws iam get-role \
  --role-name eksNodeGroupRole \
  --query 'Role.Arn' \
  --profile devops \
  --output text)

echo $EKS_NODE_ROLE_ARN

##exoected output: arn:aws:iam::386757865964:role/eksNodeGroupRole
```

---

# Step 8 - Create EKS Managed Node Group

## Console

1. Go to **Amazon EKS**.
2. Open cluster **rama-eks-cluster**.
3. Go to **Compute** tab.
4. Click **Add node group**.
5. Node group name: `rama-eks-nodegroup`.
6. Node IAM role: `eksNodeGroupRole`.
7. Instance type: `t3.medium`.
8. Disk size: `20 GiB`.
9. Desired size: `2`, minimum: `1`, maximum: `3`.
10. Select subnets.
11. Review and create node group.
12. Wait until status is **Active**.

## AWS CLI

```bash
aws eks create-nodegroup \
  --cluster-name priya-eks-cluster \
  --nodegroup-name priya-eks-nodegroup \
  --region us-east-1 \
  --subnets $SUBNET_IDS \
  --node-role $EKS_NODE_ROLE_ARN \
  --scaling-config minSize=1,maxSize=3,desiredSize=2 \
  --instance-types t3.medium \
  --disk-size 20 \
  --profile devops

aws eks wait nodegroup-active \
  --cluster-name priya-eks-cluster \
  --nodegroup-name priya-eks-nodegroup \
  --region us-east-1 \
  --profile devops

aws eks describe-nodegroup \
  --cluster-name priya-eks-cluster \
  --nodegroup-name priya-eks-nodegroup \
  --region us-east-1 \
  --query 'nodegroup.status' \
  --profile devops
```

---

# Step 9 - Configure kubectl Access

## Console

1. Open **Amazon EKS**.
2. Open cluster **priya-eks-cluster**.
3. Confirm cluster status is **Active**.
4. Use CloudShell or your terminal to run the CLI commands.

## AWS CLI / kubectl

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name priya-eks-cluster \
  --profile devops

kubectl get nodes
## if showing kebectl has not installed/located, install it:
sudo snap install kubectl --classic

aws eks list-nodegroups \
  --cluster-name priya-eks-cluster \
  --region us-east-1 \
  --profile devops
```

---

# Step 10 - Create Kubernetes Namespace

## Console

Use AWS CloudShell to create the namespace with kubectl.

## CLI / kubectl

```bash
kubectl create namespace day17-priya
kubectl get namespaces
```

---

# Step 11 - Create Kubernetes Deployment

## Console

1. Open AWS CloudShell.
2. Create a file named `deployment.yaml`.
3. Paste the YAML below.

## CLI / kubectl

```bash
cat > deployment.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: priya-ecr-app
  namespace: day17-priya
spec:
  replicas: 2
  selector:
    matchLabels:
      app: priya-ecr-app
  template:
    metadata:
      labels:
        app: priya-ecr-app
    spec:
      containers:
        - name: priya-ecr-container
          image: 386757865964.dkr.ecr.us-east-1.amazonaws.com/priya-ecr:v2
          imagePullPolicy: Always
          ports:
            - containerPort: 80
YAML

kubectl apply -f deployment.yaml
kubectl get deployments -n day17-priya
kubectl get pods -n day17-priya
kubectl describe pod priya-ecr-app-f9bfcc9d4-944sg -n day17-priya
kubectl logs priya-ecr-app-f9bfcc9d4-944sg  -n day17-priya
```

---

# Step 12 - Create Kubernetes Service

## Console

1. Open AWS CloudShell.
2. Create a file named `service.yaml`.
3. Paste the YAML below.

## CLI / kubectl

```bash
cat > service.yaml <<'YAML'
apiVersion: v1
kind: Service
metadata:
  name: priya-ecr-service
  namespace: day17-priya
spec:
  type: LoadBalancer
  selector:
    app: priya-ecr-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
YAML

kubectl apply -f service.yaml
kubectl get svc -n day17-priya
kubectl get svc priya-ecr-service -n day17-priya --watch
```

---

# Step 13 - Test the Application

## Console

1. Go to **EC2 > Load Balancers**.
2. Find the load balancer created by Kubernetes.
3. Copy the DNS name.
4. Open it in a browser.

## CLI / kubectl

```bash
export APP_URL=$(kubectl get svc priya-ecr-service \
  -n day17-priya \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo http://$APP_URL
curl http://$APP_URL
```

---
## Debug in container

``` 
kubectl run debug --rm -it \
  --image=curlimages/curl \
  --restart=Never \
  -n day17-priya -- sh
```

``` 
curl -v http://172.31.11.7:8080
curl -v http://172.31.13.20:3000
curl -v http://172.31.13.20:5000
```

# Step 14 - Verify EKS Resources

## Console

1. Go to **Amazon EKS** and open `rama-eks-cluster`.
2. Check **Overview**, **Compute**, and **Resources**.
3. Go to **EC2 > Load Balancers** and verify the load balancer.
4. Go to **ECR > rama-ecr** and verify image tag `v2`.

## AWS CLI / kubectl

```bash
aws eks describe-cluster \
  --name priya-eks-cluster \
  --region us-east-1 \
  --query 'cluster.{Name:name,Status:status,Endpoint:endpoint,Version:version}' \
  --profile devops

aws eks describe-nodegroup \
  --cluster-name priya-eks-cluster \
  --nodegroup-name priya-eks-nodegroup \
  --region us-east-1 \
  --query 'nodegroup.{Name:nodegroupName,Status:status,InstanceTypes:instanceTypes}' \
  --profile devops

kubectl get all -n day17-priya
kubectl get pods -n day17-priya -o wide
kubectl logs -n day17-priya deployment/priya-ecr-app
```

---

# Step 15 - Troubleshooting

## ImagePullBackOff

```bash
kubectl describe pod -n day17-priya

aws ecr describe-images \
  --repository-name priya-ecr \
  --image-ids imageTag=v2 \
  --region us-east-1 \
  --profile devops

aws iam list-attached-role-policies \
  --role-name eksNodeGroupRole \
  --profile devops
```

Required node role policy:

```text
AmazonEC2ContainerRegistryReadOnly
```

## Nodes Not Ready

```bash
kubectl get nodes
kubectl describe node priya-eks-nodegroup

aws eks describe-nodegroup \
  --cluster-name priya-eks-cluster \
  --nodegroup-name priya-eks-nodegroup \
  --region us-east-1 \
  --profile devops
```

## LoadBalancer Pending

```bash
kubectl describe svc priya-ecr-service -n day17-priya

aws elbv2 describe-load-balancers \
  --region us-east-1 \
  --profile devops
```

---

# Step 16 - Clean Up Resources

Use this step to avoid AWS charges.

## Console

1. Delete Kubernetes service first using CloudShell.
2. Go to **Amazon EKS**.
3. Open cluster **rama-eks-cluster**.
4. Delete node group **rama-eks-nodegroup**.
5. Delete cluster **rama-eks-cluster**.
6. Go to **IAM** and delete roles if no longer needed:
   - `eksClusterRole`
   - `eksNodeGroupRole`
7. Optional: Delete ECR repository **rama-ecr** only if the image is no longer needed.

## CLI / kubectl

```bash
kubectl delete service priya-ecr-service -n day17-priya
kubectl delete deployment priya-ecr-app -n day17-priya
kubectl delete namespace day17-priya

aws eks delete-nodegroup \
  --cluster-name priya-eks-cluster \
  --nodegroup-name priya-eks-nodegroup \
  --region us-east-1 \
  --profile devops

aws eks wait nodegroup-deleted \
  --cluster-name priya-eks-cluster \
  --nodegroup-name priya-eks-nodegroup \
  --region us-east-1 \
  --profile devops

aws eks delete-cluster \
  --name priya-eks-cluster \
  --region us-east-1 \
  --profile devops

aws eks wait cluster-deleted \
  --name priya-eks-cluster \
  --region us-east-1 \
  --profile devops

aws iam detach-role-policy \
  --role-name eksClusterRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy \
  --profile devops

aws iam delete-role --role-name eksClusterRole --profile devops

aws iam detach-role-policy \
  --role-name eksNodeGroupRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy \
  --profile devops

aws iam detach-role-policy \
  --role-name eksNodeGroupRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly \
  --profile devops

aws iam detach-role-policy \
  --role-name eksNodeGroupRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
  --profile devops

aws iam delete-role --role-name eksNodeGroupRole --profile devops
```

Optional ECR deletion:

```bash
aws ecr delete-repository \
  --repository-name priya-ecr \
  --region us-east-1 \
  --force
```

---

# Final Validation Checklist

- ECR repository `rama-ecr` exists.
- Image `rama-ecr:v2` exists in ECR.
- EKS cluster `rama-eks-cluster` is Active.
- Managed node group `rama-eks-nodegroup` is Active.
- `kubectl get nodes` shows Ready nodes.
- Namespace `day17` exists.
- Deployment `rama-ecr-app` is running.
- Service `rama-ecr-service` has an external LoadBalancer URL.
- Application is accessible using browser or curl.
