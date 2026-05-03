variable "name_prefix" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "ecr_repository_url" { type = string }
variable "image_tag" { type = string }
variable "execution_role_arn" { type = string }
variable "task_role_arn" { type = string }
variable "log_group_name" { type = string }
variable "allowed_ingress_cidr" { type = string }

resource "aws_ecs_cluster" "this" {
  name = "${var.name_prefix}-cluster"
}

resource "aws_security_group" "api" {
  name   = "${var.name_prefix}-api-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ingress_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "api" {
  family                   = "${var.name_prefix}-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name         = "api"
      image        = "${var.ecr_repository_url}:${var.image_tag}"
      essential    = true
      portMappings = [{ containerPort = 8000, hostPort = 8000, protocol = "tcp" }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "api"
        }
      }
    }
  ])
}

data "aws_region" "current" {}

resource "aws_ecs_service" "api" {
  name            = "${var.name_prefix}-api-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [aws_security_group.api.id]
    assign_public_ip = true
  }
}

output "cluster_name" { value = aws_ecs_cluster.this.name }
output "service_name" { value = aws_ecs_service.api.name }
