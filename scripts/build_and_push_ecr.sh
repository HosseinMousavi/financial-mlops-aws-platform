#!/usr/bin/env bash
set -euo pipefail

AWS_REGION=${AWS_REGION:-us-east-1}
IMAGE_TAG=${IMAGE_TAG:-latest}

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

API_REPO=$(cd infra/terraform && terraform output -raw api_ecr_repository)
TRAIN_REPO=$(cd infra/terraform && terraform output -raw train_ecr_repository)
SAGEMAKER_REPO=$(cd infra/terraform && terraform output -raw sagemaker_ecr_repository)

docker build -f docker/Dockerfile.serve -t "$API_REPO:$IMAGE_TAG" .
docker push "$API_REPO:$IMAGE_TAG"

docker build -f docker/Dockerfile.train -t "$TRAIN_REPO:$IMAGE_TAG" .
docker push "$TRAIN_REPO:$IMAGE_TAG"

docker build -f docker/Dockerfile.sagemaker -t "$SAGEMAKER_REPO:$IMAGE_TAG" .
docker push "$SAGEMAKER_REPO:$IMAGE_TAG"
