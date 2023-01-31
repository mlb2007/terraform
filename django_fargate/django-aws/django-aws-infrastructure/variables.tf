variable "region" {
  description = "The AWS region to create resources in."
  default     = "us-west-2"
}

variable "project_name" {
  description = "Project name to use in resource names"
  default     = "django-aws"
}

variable "availability_zones" {
  description = "Availability zones"
  default     = ["us-west-2a", "us-west-2c"]
}

variable "ecs_prod_backend_retention_days" {
  description = "Retention period for backend logs"
  default     = 30
}

variable "docker_image_url_django" {
  description = "Docker image to run in the ECS cluster"
  default  = "072507290151.dkr.ecr.us-west-2.amazonaws.com/django-aws-backend:latest"
}

# AWS secrets manager
data "aws_secretsmanager_secret_version" "creds" {
  # Fill in the name you gave to your secret
  secret_id = "rds/rds_password"
}

# locals are MODULE local and not file local .. nice ..
locals {
  db_name = "django_aws"
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)
  db_instance_class = "db.t4g.micro"
}

###### OUTPUT ############
output "db_rds_username" {
  value = local.db_creds.username
  sensitive = true
}

output "db_rds_password" {
  value = local.db_creds.password
  sensitive = true
}
##########################



