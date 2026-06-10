#!/usr/bin/env bash
set -euo pipefail

export AWS_REGION=us-east-1
export AWS_PROFILE=devops
export STACK_NAME=priya-eks-day17-stack

kubectl delete service priya-ecr-service -n day17-priya --ignore-not-found=true
kubectl delete deployment priya-ecr-app -n day17-priya --ignore-not-found=true
kubectl delete namespace day17-priya --ignore-not-found=true

aws cloudformation delete-stack \
  --stack-name "$STACK_NAME" \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE"

aws cloudformation wait stack-delete-complete \
  --stack-name "$STACK_NAME" \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE"
