output "raw_bucket" { value = module.storage.raw_bucket_name }
output "processed_bucket" { value = module.storage.processed_bucket_name }
output "artifact_bucket" { value = module.storage.artifact_bucket_name }
output "api_ecr_repository" { value = module.ecr.api_repository_url }
output "train_ecr_repository" { value = module.ecr.train_repository_url }
output "sagemaker_ecr_repository" { value = module.ecr.sagemaker_repository_url }
output "ecs_service_name" {
  value = var.enable_ecs ? module.ecs[0].service_name : null
}
output "ecs_cluster_name" {
  value = var.enable_ecs ? module.ecs[0].cluster_name : null
}
output "sagemaker_endpoint_name" {
  value = var.enable_sagemaker ? module.sagemaker[0].endpoint_name : null
}
output "ec2_public_ip" {
  value = var.enable_ec2 ? module.ec2[0].public_ip : null
}