#! /bin/bash

REGION=${1-'us-west-2'}
ECS_CLUSTER_NAME='prod'
SERVICE_NAME='prod-backend-web'

TASK_ID=$(aws ecs list-tasks --cluster ${ECS_CLUSTER_NAME} --service-name ${SERVICE_NAME}  --query 'taskArns[0]' --output text  | awk '{split($0,a,"/"); print a[3]}')

aws ecs execute-command --task $TASK_ID --command "bash" --interactive --cluster ${ECS_CLUSTER_NAME} --region ${REGION}
