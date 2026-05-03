resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  name_prefix = "${var.project_name}-${var.environment}-${random_id.suffix.hex}"
}

module "network" {
  source              = "./modules/network"
  name_prefix         = local.name_prefix
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
}

module "storage" {
  source      = "./modules/s3"
  name_prefix = local.name_prefix
}

module "ecr" {
  source      = "./modules/ecr"
  name_prefix = local.name_prefix
}

module "iam" {
  source               = "./modules/iam"
  name_prefix          = local.name_prefix
  artifact_bucket_arn  = module.storage.artifact_bucket_arn
  raw_bucket_arn       = module.storage.raw_bucket_arn
  processed_bucket_arn = module.storage.processed_bucket_arn
}

module "cloudwatch" {
  source      = "./modules/cloudwatch"
  name_prefix = local.name_prefix
}

module "ec2" {
  source               = "./modules/ec2"
  name_prefix          = local.name_prefix
  vpc_id               = module.network.vpc_id
  subnet_id            = module.network.public_subnet_ids[0]
  instance_type        = var.instance_type
  allowed_ingress_cidr = var.allowed_ingress_cidr
  instance_profile     = module.iam.ec2_instance_profile_name
  count                = var.enable_ec2 ? 1 : 0
}

module "ecs" {
  source               = "./modules/ecs"
  name_prefix          = local.name_prefix
  vpc_id               = module.network.vpc_id
  public_subnet_ids    = module.network.public_subnet_ids
  ecr_repository_url   = module.ecr.api_repository_url
  image_tag            = var.model_image_tag
  execution_role_arn   = module.iam.ecs_task_execution_role_arn
  task_role_arn        = module.iam.ecs_task_role_arn
  log_group_name       = module.cloudwatch.ecs_log_group_name
  allowed_ingress_cidr = var.allowed_ingress_cidr
  count                = var.enable_ecs ? 1 : 0
}

module "sagemaker" {
  source             = "./modules/sagemaker"
  name_prefix        = local.name_prefix
  model_image        = "${module.ecr.sagemaker_repository_url}:${var.model_image_tag}"
  execution_role_arn = module.iam.sagemaker_execution_role_arn
  artifact_bucket    = module.storage.artifact_bucket_name
  count              = var.enable_sagemaker ? 1 : 0
}
