# Ref: https://medium.com/@hmalgewatta/setting-up-an-aws-ec2-instance-with-ssh-access-using-terraform-c336c812322f
# Iam roles: https://skundunotes.com/2021/11/16/attach-iam-role-to-aws-ec2-instance-using-terraform/
#
variable "region" {
  description = "The AWS region to create resources in."
  default     = "us-west-2"
}

variable "project_name" {
  description = "Project name to use in resource names"
  default     = "ec2-instance-aws"
}

variable "availability_zones" {
  description = "Availability zones"
  default     = ["us-west-2a", "us-west-2c"]
}

variable "log_retention_days" {
  description = "Retention period for backend logs"
  default     = 30
}

variable "ami_id" {
  description = "Which AMI to spawn."
  default = "ami-06e85d4c3149db26a"
}

variable "ami_name" {
  description = "Which AMI to spawn."
  default = "AMZ-Linux-X64"
}


variable "ec2-instance-type" {
  default = "t2.micro"
}

