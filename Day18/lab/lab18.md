## Create the Repository in ECR
aws ecr create-repository \
--repository-name priya-ecr \
--region us-east-1 --profile devops

## Authenticate Docker

```bash
aws ecr get-login-password \
--region us-east-1 --profile devops | \
docker login \
--username AWS \
--password-stdin \
386757865964.dkr.ecr.us-east-1.amazonaws.com
```

## Push Image to ECR

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
