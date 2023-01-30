# Production cluster
resource "aws_ecs_cluster" "prod" {
  name = "prod"
}

# Backend web task definition and service
resource "aws_ecs_task_definition" "prod_backend_web" {
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  family = "backend-web"
  
  # 
  # start the container, i.e. django using guincorn webserver 
  # the container definitions format is not the same as shown below,
  # so we have a template file with substitutions and we get the properly
  # formatted container task definition
  #
  container_definitions = templatefile(
    "templates/backend_container.json.tpl",
    {
      region     = var.region
      name       = "prod-backend-web"
      #image      = aws_ecr_repository.backend.repository_url
      image      = var.docker_image_url_django  
      command    = ["gunicorn", "-w", "3", "-b", ":8000", "django_aws.wsgi:application"]
      log_group  = aws_cloudwatch_log_group.prod_backend.name
      log_stream = aws_cloudwatch_log_stream.prod_backend_web.name
    },
  )
  # required for calling APIs on behalf of ECS instance
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  
  # required to run the container task, in this case, the Django task
  task_role_arn      = aws_iam_role.prod_backend_task.arn
}

# Load balancer calls the ECS service which in turn calls instances to run
# tasks on those instances
#
resource "aws_ecs_service" "prod_backend_web" {
  name                               = "prod-backend-web"
  
  cluster                            = aws_ecs_cluster.prod.id
  
  # note the task to be done ...
  task_definition                    = aws_ecs_task_definition.prod_backend_web.arn
  
  desired_count                      = 1
  
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  # who is my service's load balancer ? 
  load_balancer {
    target_group_arn = aws_lb_target_group.prod_backend.arn
    container_name   = "prod-backend-web"
    container_port   = 8000
  }

  # All my instances spawned need to be in private subnet
  network_configuration {
    security_groups  = [aws_security_group.prod_ecs_backend.id]
    subnets          = [aws_subnet.prod_private_1.id, aws_subnet.prod_private_2.id]
    assign_public_ip = false
  }

  # to peer into ECS instance 
  platform_version = "1.4.0"
  enable_execute_command = true

}

# Security Group
# the backend, the ECS service belong to the security group
# of ALB and so can only interact with it and no-one else
#
resource "aws_security_group" "prod_ecs_backend" {
  name        = "prod-ecs-backend"
  vpc_id      = aws_vpc.prod.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.prod_lb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM roles and policies
resource "aws_iam_role" "prod_backend_task" {
  name = "prod-backend-task"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "ecs-task-execution"

  # 
  # if someone wants to assume this role, is there a policy for it ?
  # Yes, only ecs-tasks.amazonaws.com can assume this role and that "principal"
  # can do one action, which is "sts:AssumeRole"
  #
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Action = "sts:AssumeRole",
          Principal = {
            Service = "ecs-tasks.amazonaws.com"
          },
          Effect = "Allow",
          Sid    = ""
        }
      ]
    }
  )
}

## instead of hardcodings above, we can use data and refer to this data above
# Do we need to jsonencode this ?
#data "aws_iam_policy_document" "ecs_task_assume_role" {
#  statement {
#    actions = ["sts:AssumeRole"]
#
#    principals {
#      type = "Service"
#      identifiers = ["ecs-tasks.amazonaws.com"]
#    }
#  }
#}


# Now the IAM role must have some policy. In this case it simply copies
# the policy that allows ECS tasks to be executed in this role ...
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution.name

  # this is hard coded AWS task execution policy ...
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

}

# Cloudwatch Logs
resource "aws_cloudwatch_log_group" "prod_backend" {
  name              = "prod-backend"
  retention_in_days = var.ecs_prod_backend_retention_days
}

resource "aws_cloudwatch_log_stream" "prod_backend_web" {
  name           = "prod-backend-web"
  log_group_name = aws_cloudwatch_log_group.prod_backend.name
}

