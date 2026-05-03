variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Project name prefix"
  default     = "financial-mlops"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
  default     = "dev"
}

variable "vpc_cidr" {
  type    = string
  default = "10.50.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.50.1.0/24", "10.50.2.0/24"]
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for lightweight ops host"
  default     = "t3.micro"
}

variable "allowed_ingress_cidr" {
  type        = string
  description = "CIDR allowed to access dev ports. For production, restrict to VPN or office IP."
  default     = "0.0.0.0/0"
}

variable "model_image_tag" {
  type        = string
  description = "Container image tag for ECS and SageMaker"
  default     = "latest"
}

variable "enable_ec2" {
  description = "Whether to create EC2 ops instance"
  type        = bool
  default     = false
}

variable "enable_sagemaker" {
  description = "Whether to create SageMaker endpoint"
  type        = bool
  default     = false
}

variable "enable_ecs" {
  description = "Whether to create ECS API service"
  type        = bool
  default     = false
}