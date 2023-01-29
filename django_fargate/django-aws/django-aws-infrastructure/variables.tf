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
