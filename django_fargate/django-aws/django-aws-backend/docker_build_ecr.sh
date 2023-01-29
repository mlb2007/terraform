#! /bin/bash
#docker buildx build --platform=linux/amd64

# AWS account ID
ACCOUNT_ID=${1-072507290151}

REGION=${2-'us-west-2'}

IMAGE_NAME=${3-'django-aws-backend:latest'}

echo "Build docker image:${IMAGE_NAME}"
docker buildx build --platform=linux/amd64 -t ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${IMAGE_NAME} .

echo "Login into AWS ECR" 
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

echo "docker push ${IMAGE_NAME} to ECR"
docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${IMAGE_NAME}

