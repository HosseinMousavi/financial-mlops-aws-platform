aws_region           = "us-east-1"
project_name         = "financial-mlops"
environment          = "dev"
instance_type        = "t3.micro"
allowed_ingress_cidr = "0.0.0.0/0"
model_image_tag      = "latest"

enable_ec2       = false
enable_sagemaker = false

enable_ecs = false