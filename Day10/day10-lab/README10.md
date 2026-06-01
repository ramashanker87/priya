# Lab-01
# For priya-s3-stack.yaml
===================================
aws cloudformation create-stack \
--stack-name priya-s3-demo-stack \
--template-body file://priya-s3-stack.yaml \
--parameters ParameterKey=EnvironmentName,ParameterValue=dev \
--profile devops

Verify Deployment of priya-s3-stack:

aws cloudformation describe-stacks \
--stack-name priya-s3-demo-stack \
--profile devops
=====================================================================================
#Lab 2 — Nested Stacks
network.yaml
# Step 2 — Create S3 Bucket

```bash
aws s3 mb s3://cf-template-storage-demo-priya --profile devops

parent-stack.yaml
===================================
aws cloudformation create-stack \
--stack-name parent-stack-priya \
--template-body file://parent-stack.yaml \
--profile devops