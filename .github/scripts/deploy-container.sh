#!/bin/bash
set -e

# Checking all env variables
variables=("REPO" "MICROSERVICE_NAME" "IMAGE_TAG" "INSTANCE_ID" "CONTAINER_NAME" "PORT" "DOCKER_USERNAME" "DOCKER_PASSWORD" "GEMINI_API_KEY")

for var in "${variables[@]}"; do
  if [ -z "${!var}" ]; then
    echo "::error::Missing required environment variable: $var"
    exit 1
  fi
done

IMAGE_NAME="${REPO}:${IMAGE_TAG}"
echo "Using Docker image: ${IMAGE_NAME}"

EXTRA_ENV=""
DB_PORT=${DB_PORT:-5432}

case "$MICROSERVICE_NAME" in
  dotnet)
  echo "Fetching DB credentials dynamically from AWS Secrets Manager..."
  
  # Automatically retrieve RDS instance identifier and get its private IP (Host)

  RDS_IDENTIFIER=$(aws rds describe-db-instances \
    --query "DBInstances[0].DBInstanceIdentifier" \
    --output text)

  if [ -z "$RDS_IDENTIFIER" ]; then
    echo "::error::Unable to fetch RDS instance identifier. Please check your RDS instances."
    exit 1
  fi

  echo "Detected RDS Instance Identifier: ${RDS_IDENTIFIER}"
 
  # Get Private IP of RDS (Host)

  DB_HOST=$(aws rds describe-db-instances \
    --db-instance-identifier "$RDS_IDENTIFIER" \
    --query "DBInstances[0].Endpoint.Address" \
    --output text)

  if [ -z "$DB_HOST" ]; then
    echo "::error::Unable to fetch RDS endpoint for my-postgres-db"
    exit 1
  fi

  echo "RDS Host (DB_HOST): ${DB_HOST}"

  # Auto search of secret RDS by name
  SECRET_ID=$(aws secretsmanager list-secrets \
      --query "SecretList[?contains(Name,'rds!db')].Name" \
      --output text | head -n1)

  if [ -z "$SECRET_ID" ]; then
      echo "::error::RDS secret not found!"
      exit 1
  fi

  # Get username и password
  DB_CREDENTIALS=$(aws secretsmanager get-secret-value \
      --secret-id "$SECRET_ID" \
      --query SecretString \
      --output text)

  DB_USER=$(echo "$DB_CREDENTIALS" | jq -r '.username')
  DB_PASSWORD=$(echo "$DB_CREDENTIALS" | jq -r '.password')

   if [[ -z "$DB_USER" || -z "$DB_PASSWORD" ]]; then
    echo "::error::Failed to fetch DB credentials from Secrets Manager"
    exit 1
  fi

  DB_NAME="itm"  

  CONNECTIONSTRING="Host=${DB_HOST};Port=${DB_PORT};Database=${DB_NAME};Username=${DB_USER};Password=${DB_PASSWORD};"

  ESCAPED_CONNECTIONSTRING=${CONNECTIONSTRING//\$/\\\$}
  EXTRA_ENV="-e ASPNETCORE_ENVIRONMENT=Development -e ConnectionStrings__DbConnectionString=\"$ESCAPED_CONNECTIONSTRING\" -e GOOGLE_API_KEY=\"${GEMINI_API_KEY}\""

  echo "Generated ConnectionString: ${CONNECTIONSTRING}"
  ;;

  angular|react)
  echo "Setting environment variables for frontend service (${MICROSERVICE_NAME})..."

  ;;

  *)
    echo "::error::Unknown MICROSERVICE_NAME: ${MICROSERVICE_NAME}"
    exit 1
    ;;
esac
# Form SMM command -added {EXTRA_ENV} to docker run

COMMAND_ID=$(aws ssm send-command \
  --instance-ids "${INSTANCE_ID}" \
  --document-name "AWS-RunShellScript" \
  --parameters "commands=[
    'echo \"Logging in to Docker registry...\"',
    'echo \"${DOCKER_PASSWORD}\" | docker login -u ${DOCKER_USERNAME} --password-stdin',
    'echo \"Login complete, deploying container for ${MICROSERVICE_NAME} from image ${IMAGE_NAME} on port ${PORT}\"',
    'docker container rm -f ${CONTAINER_NAME} || true',
    'docker image prune -f',
    'docker pull ${IMAGE_NAME}',
    'docker run -d --name ${CONTAINER_NAME} -p ${PORT}:${PORT} ${EXTRA_ENV} --restart always ${IMAGE_NAME}',
    'docker ps -f name=${CONTAINER_NAME}',
    'sleep 3',
    'docker logs ${CONTAINER_NAME} --tail 20'
  ]" \
  --query "Command.CommandId" \
  --output text)

sleep 5

echo "Command ID: $COMMAND_ID"
echo "Waiting for deployment to complete..."

for i in {1..12}; do
  STATUS=$(aws ssm get-command-invocation \
    --command-id "$COMMAND_ID" \
    --instance-id "${INSTANCE_ID}" \
    --query "Status" \
    --output text 2>/dev/null || echo "Pending")

  echo "Deployment status: $STATUS"
  
  if [ "$STATUS" == "Success" ]; then
    break
  elif [ "$STATUS" == "Failed" ] || [ "$STATUS" == "Cancelled" ] || [ "$STATUS" == "TimedOut" ]; then
    echo "::error::Deployment failed with status: $STATUS"
    
    # Get error details in case of any errors
    aws ssm get-command-invocation \
      --command-id "$COMMAND_ID" \
      --instance-id "${INSTANCE_ID}" \
      --query "StandardErrorContent" \
      --output text
    
    exit 1
  fi
  
  sleep 10
done

# Get result
OUTPUT=$(aws ssm get-command-invocation \
  --command-id "$COMMAND_ID" \
  --instance-id "${INSTANCE_ID}" \
  --query "StandardOutputContent" \
  --output text)

echo "Deployment output:"
echo "$OUTPUT"